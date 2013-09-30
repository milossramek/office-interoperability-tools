# pip install Wand
#from __future__ import print_function
import SimpleITK as sitk
import dolib
import numpy as np
import sys, os, tempfile
import getopt
import ipdb
#from scipy import sparse
#ipdb.set_trace()

class MyException(Exception):
	def __init__(self, what):
		self.what = what

def overlapIndexPage(iarray1, iarray2):
	"""
	Compute the pixel overlap index without page or line alignment
	"""
	(ystart, xstart), (ystop, xstop) = dolib.getBBox(iarray1, iarray2)
	itrim1 = iarray1[ystart:ystop, xstart:xstop].astype(np.uint8)
	itrim2 = iarray2[ystart:ystop, xstart:xstop].astype(np.uint8)
	#return 2.0* np.sum((itrim1+itrim2) > 1) / (np.sum(itrim1) + np.sum(itrim2))
	diff = itrim1 != itrim2
	ovl = 100*(1.0 - float(np.sum(diff)) / (np.sum(itrim2) + np.sum(itrim1)))
	rslt = '*PgPxOvl[%%]: %2.1f*'%ovl
	return rslt

def lineIndexPage(iarray0, iarray1):
	"""
	compute similarity measures for each page line, compute statistics and return it in a string form
	"""
	# crop the first image and segment it to lines
	(ystart0, xstart0), (ystop0, xstop0) = dolib.getBBox(iarray0)
	itrim0 = iarray0[ystart0:ystop0, xstart0:xstop0].astype(np.uint8)
	tx0, sp0 = dolib.GetLineSegments(itrim0)
	
	# crop the second image and segment it to lines
	(ystart1, xstart1), (ystop1, xstop1) = dolib.getBBox(iarray1)
	itrim1 = iarray1[ystart1:ystop1, xstart1:xstop1].astype(np.uint8)
	tx1, sp1 = dolib.GetLineSegments(itrim1)

	#create a page view to display adjusted overlays, taking line spaces from the source (first) page
	newpage = np.zeros((iarray0.shape[0], iarray0.shape[1], 3), dtype=np.uint8)
	newpage[:] = 1

	corrlines=[]
	indices=[]
	for i in range(min(len(tx0),len(tx1))):
		cline, ind = dolib.alignLineIndex(dolib.GetLine(itrim0, tx0, i), dolib.GetLine(itrim1, tx1, i))
		corrlines.append(cline)
		indices.append(ind)
	indices = np.array(indices)

	ar=ystart0	#the actual row
	for i in range(min(len(tx0),len(tx1))-1):
		newpage[ar:ar+corrlines[i].shape[0],xstart0:xstart0+corrlines[i].shape[1]] = corrlines[i]
		ar += corrlines[i].shape[0] + sp0[i][1]
	newpage[ar:ar+corrlines[-1].shape[0],xstart0:xstart0+corrlines[-1].shape[1]] = corrlines[-1]

	#height error in pixels
	heightErr=abs(float(itrim0.shape[0]-itrim1.shape[0]))
	#normalized height error in pixels
	heightErr = heightErr * (dpi*a4height/i2mm)/float(itrim0.shape[0]+itrim1.shape[0])

	#If changing the rslt format, adjust the gentestviews.sh script accordingly
	rslt = 'LnPxOvl[%%]: %2.1f*LnMaxDist avg: %2.2f*std: %2.2f*max: %2.1f*med: %2.2f*PgHeightErr: %2.2f*HorLnShiftMax:%2.2f*nLinesDif:%2d'
	rslt = rslt%(100*np.average(indices[:,1]), px2mm(np.average(indices[:,3])), px2mm(np.std(indices[:,3])), px2mm(np.max(indices[:,3])), px2mm(np.median(indices[:,3])),px2mm(heightErr),px2mm(np.max(indices[:,0])),len(tx1)-len(tx0)) 
	return 1-newpage, rslt

def annotateImg(ifile, color, size, geometry, text):
	cmd = 'convert -fill %s -pointSize %d -annotate %s %s %s %s'
	cmd = cmd%(color, size, geometry, text, ifile, ifile)
	os.system(cmd)

def genside (tfile1, tfile2, height, width, name1, name2, txt1, txt2, outfile):
	"""
	create a side-by-side view
	tn1, tn2: images
	name1, name2: their names 
	txt1, txt2: some text
	"""

	if annotated:
		annotateImg(tfile1, 'blue', mm2px(4), '+%d+%d'%(mm2px(4),mm2px(4)), '"'+'Source: '+name1+'\n'+txt1+'"')
		annotateImg(tfile2, 'blue', mm2px(4), '+%d+%d'%(mm2px(4),mm2px(4)), '"'+'Target: '+name2+'\n'+txt2+'"')
	cmd = 'montage -compress lzw -geometry "%d"x"%d"+1+1 -border 3 %s %s %s'%(width, height, tfile1, tfile2, outfile)
	os.system(cmd)	

def genoverlay(img1, title, name1, name2, txt, outfile, img2=None):
	"""
	create an overlayed view
	img1, img2: images
	title: kind of title to print
	name1, name2: their names 
	txt: text to print below the title
	"""

	tn3 = dolib.tmpname()+'.tif'
	if img2 == None:
		sitk.WriteImage(sitk.GetImageFromArray(255*(1-img1), isVector=True), tn3)
	else:
		#overlay the images (#2 twice to make it cyan)
		tn1 = dolib.tmpname()+'.tif'
		tn2 = dolib.tmpname()+'.tif'
		sitk.WriteImage(sitk.GetImageFromArray(255*(1-img1)), tn1)
		sitk.WriteImage(sitk.GetImageFromArray(255*(1-img2)), tn2)
		#sitk.WriteImage(sitk.GetImageFromArray(img1), tn1)
		#sitk.WriteImage(sitk.GetImageFromArray(img2), tn2)
		cmd ='convert -compress lzw  %s %s %s -background white -channel red,green,blue  -combine %s'
		#cmd ='convert %s %s %s -background white -channel red,green,blue  -combine %s'
		cmd =cmd%(tn1, tn2, tn2, tn3)
		os.system(cmd)
		os.unlink(tn1)
		os.unlink(tn2)

	if annotated:
		cmd = 'convert -compress lzw %s -fill blue -pointSize %d -annotate +%d+%d "%s\ncyan: %s\nred: %s\n%s" %s'
		#cmd = 'convert %s -fill blue -pointSize %d -annotate +%d+%d "%s\ncyan: %s\nred: %s\n%s" %s'
		cmd = cmd%(tn3, mm2px(3), mm2px(4), mm2px(4), title, name1, name2, txt, outfile)  
		os.system(cmd)
	else:
		os.system('cp %s %s'%(tn3, outfile))

	os.unlink(tn3)

def mm2px(val):
	"""
	convert 'val' im mm to pixels
	"""
	global dpi, i2mm
	return int(val*dpi/i2mm)
#
# docompare.py v1.0 - 2013-09-30
#
# This script generates csv files with numeric evaluations and pair views from printed document files
#
# Copyright (C) 2013 Milos Sramek <milos.sramek@soit.sk>
# Licensed under the GNU LGPL v3 - http://www.gnu.org/licenses/gpl.html
# - or any later version.
#

def px2mm(val):
	"""
	convert 'val' im mm to pixels
	"""
	global dpi, i2mm
	return val*i2mm/dpi

def usage(desc):
	global outfile
	print sys.argv[0]+':',  desc
	print "Usage: ", sys.argv[0], "[options]", "source.pdf target.pdf"
	print "\t-o ................ file to store output images to {default:"+outfile+'}'
	#print "\t-p ................ report the results of individual pages {default: whole document}"
	#print "\t-fp ............... use only the first page {default: all pages}"
	print "\t-d ................ resolution of the converted pdf documen {default: "+str(dpi)+"}"
	print "\t-a ................ annotate each page with file name {default: no annotation}"
	print "\t-l ................ create overlayed unaligned images {default: side-by-side placement}"
	print "\t-g ................ create overlayed row-aligned images {default: side-by-side placement}"
	print "\t-v ................ be verbose"
	print "\t-h ................ this usage"

def parsecmd(desc):
	global verbose, dpi, Names, annotated, overlayed, outfile, rowaligned
	try:
		opts, Names = getopt.getopt(sys.argv[1:], "hvalgo:d:", ["help", "verbose"])
	except getopt.GetoptError as err:
		# print help information and exit:
		print str(err) # will print something like "option -a not recognized"
		usage(desc)
		sys.exit(2)
	for o, a in opts:
		if o in ("-v", "--verbose"):
			verbose = True
		elif o in ("-h", "--help"):
			usage(desc)
			sys.exit()
		elif o in ("-a"):
			annotated = True
		elif o in ("-l"):
			annotated = True
			overlayed = True
		elif o in ("-g"):
			rowaligned = True
			annotated = True
		elif o in ("-o"):
			outfile = a
		elif o in ("-d"):
			dpi = int(a)
		else:
			assert False, "unhandled option"
		# ...
#global definitions
a4width=210
a4height=297
i2mm=25.4	# inch to mm conversion
annotated = False
overlayed = False
rowaligned = False
progdesc="Compare two pdf documents and return some statistics"
verbose = False
outfile = "cmp.pdf"
dpi = 200
parsecmd(progdesc)
#ipdb.set_trace()
if Names == []:
	usage(progdesc)
	sys.exit(1)

try:
	img1, tname1 = dolib.pdf2array(Names[0], dpi)
	img2, tname2 = dolib.pdf2array(Names[1], dpi)

	#crop to common size first
	s1 = img1.shape
	s2 = img2.shape
	s=np.minimum(s1,s2)
	img1 = img1[:s[0],:s[1]]
	img2 = img2[:s[0],:s[1]]

	#ipdb.set_trace()
	plainOvlRslt = overlapIndexPage(dolib.toBin(img1), dolib.toBin(img2))
	lineOvlPage, lineOvlRslt = lineIndexPage(dolib.toBin(img1), dolib.toBin(img2))
	rslt = plainOvlRslt+lineOvlRslt

	if overlayed:
		genoverlay(dolib.toBin(img1), 'Page overlay', Names[0], Names[1], rslt.replace('*',' '), outfile, img2=dolib.toBin(img2)) 
	elif rowaligned:
		genoverlay(lineOvlPage, 'Aligned row overlay', Names[0], Names[1], rslt.replace('*',' '), outfile) 
	else:
		genside(tname1, tname2, s[0], s[1], Names[0], Names[1], rslt.replace('*',' '), '', outfile) 

	cmd = 'exiftool -overwrite_original -Custom1="%s" %s >/dev/null'%(rslt.replace('*',':'), outfile)
	os.system(cmd)
	os.unlink(tname1)
	os.unlink(tname2)
except MyException, e:
	sys.stderr.write(e.what+"("+Names[0]+", "+Names[1]+")\n")
