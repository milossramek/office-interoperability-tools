#! /usr/bin/python
# docompare.py v1.0 - 2013-09-30
#
# This script generates csv files with numeric evaluations and pair views from printed document files
#
# Copyright (C) 2013 Milos Sramek <milos.sramek@soit.sk>
# Licensed under the GNU LGPL v3 - http://www.gnu.org/licenses/gpl.html
# - or any later version.
#
#from __future__ import print_function
import dolib
import numpy as np
import cv2, Image
import sys, getopt, os, tempfile
import ipdb
from idisp import disp
#ipdb.set_trace()
from tifffile import TIFFfile

def tmpname():
	f = tempfile.NamedTemporaryFile(delete=True)
	f.close()
	return f.name

def pdf2array(pdffile, res=300):
	"""
	read pdf file and convert it to numpy array
	return list of pages and dimensions
	"""
	tname = tmpname()+'.tif'
	cmd = 'cat %s | gs -dQUIET -dNOPAUSE -sDEVICE=tiffgray -r%d -sOutputFile=%s - 2>/dev/null'%(pdffile, res, tname)
	os.system(cmd)
        #ipdb.set_trace()
	if not os.path.exists(tname): return None, None
        imgfile = TIFFfile(tname)
        pages = [p.asarray() for p in imgfile.pages[:2]]    # first two pages only
        shapes = [p.shape for p in imgfile.pages[:2]]
        os.remove(tname)
        return pages, shapes

def makeSingle(pages, shapes):
        ''' merge pages to one image'''
        height=0
        width=0

        for s in shapes:
            height += s[0]
            width = max(width, s[1])
        bigpage = np.zeros((height,width), dtype=pages[0].dtype)
        pos=0
        for p, s in zip(pages, shapes):
            #p[-1,:]=0
            #p[-2,:]=0
            bigpage[pos:pos+s[0],0:s[1]]=p[0:s[0],0:s[1]]
            pos += s[0]
        return bigpage

def getPagePixelOverlayIndex(iarray1, iarray2):
	"""
	Compute the pixel overlap index without page or line alignment
	"""
	(ystart, xstart), (ystop, xstop) = getBBox(iarray1, iarray2)
	itrim1 = iarray1[ystart:ystop, xstart:xstop].astype(np.uint8)
	itrim2 = iarray2[ystart:ystop, xstart:xstop].astype(np.uint8)
	#return 2.0* np.sum((itrim1+itrim2) > 1) / (np.sum(itrim1) + np.sum(itrim2))
	diff = itrim1 != itrim2
	ovl = 100*(1.0 - float(np.sum(diff)) / (np.sum(itrim2) + np.sum(itrim1)))
        rslt = 'PagePixelOvelayIndex[%%]: %2.1f | '%ovl
	return rslt

def identMerged(tx0, sp0, tx1, sp1):
    """ check, if some lines are just merged rather than missing"""
    if len(tx0) > len (tx1):
        tx=tx1; sp=sp1
        tx1=tx0; sp1=sp0
        tx0=tx; sp0=sp

    #ipdb.set_trace()
    #compute difference to text-space-text sum in longer array
    txx=[]
    for i in range(len(tx0)):
        tx=tx1[i][1] + sp1[i][1] + tx1[i+1][1]
        txx.append(tx - tx0[i][1])
    cc=np.argmin(txx)
    corrected=False
    txmin=min( np.array(tx1)[:,1] ) # minimal line heigh, used at detection threshold
    if txx[cc] < txmin/2: #expected to be near 0
        tx1[cc][1] += sp1[cc][1] + tx1[cc+1][1]
        #tx1[cc][1] = txx[cc]
        tx1 = tx1[:cc+1]+tx1[cc+2:]
        sp1 = sp1[:cc]+sp1[cc+1:]
        corrected=True

    if len(tx0) > len (tx1):
        return tx1, sp1, tx0, sp0, corrected
    else:
        return tx0, sp0, tx1, sp1, corrected

def ovlLine(im1, im2, shift=0):
	"""
	overlay two lines with different height
	"""
	im=np.zeros((max(im1.shape[0],im2.shape[0]) , im1.shape[1], 3))
	if im1.shape[0] < im2.shape[0]:
		im[shift:,:,0] = 1-im1
		im[:,:,1] = 1-im2
		im[:,:,2] = 1-im2
	else:
		im[:,:,0] = 1-im1
		im[shift:,:,1] = 1-im2
		im[shift:,:,2] = 1-im2
	return im

def alignLineIndex(l1, l2, halign=True):
	"""
	compute several line similarity measures with horizontal and vertical alignment
	"""
	# align in the horizontal direction first
	# estimate horizontal position error by correletion
	cw = min(l2.shape[1],l1.shape[1])
	l1 = l1[:,:cw]
	l2 = l2[:,:cw]

	sc1 = np.sum(l1, axis=0)
	sc2 = np.sum(l2, axis=0)
	cor = np.correlate(sc1,sc2,"same")
	horizPosErr =  np.argmax(cor)-sc1.shape[0]/2

	# align the row horizontally
	if halign == False: horizPosErr = 0
	l2c = l2.copy()
	l2c[:] = 0
	if horizPosErr > 0:
		l2c[:,horizPosErr:] = l2[:,:-horizPosErr]
		l2 = l2c
	elif horizPosErr < 0:
		l2c[:,:horizPosErr] = l2[:,-horizPosErr:]
		l2 = l2c
		#ipdb.set_trace()

	# find position with best alignment in the vertical direction
	#sum along rows
	sr1 = np.sum(l1, axis=1)
	sr2 = np.sum(l2, axis=1)

	#swap so that sr2 is the one with more lines
	if len(sr1) > len(sr2):
		aux=l1
		l1=l2
		l2=aux

	sizedif = l2.shape[0] - l1.shape[0]
	ovlaps=np.zeros(sizedif+1)
	for i in range(sizedif+1):
		ll2 = l2[i:i+l1.shape[0]]
		ll1 = l1
		diff = ll1 != ll2
                if np.sum(ll2) + np.sum(ll1) == 0:
		    ovlaps[i] = 1.0
                else:
		    ovlaps[i] = 1.0 - float(np.sum(diff)) / (np.sum(ll2) + np.sum(ll1))

	bf = ovlaps.argmax(); # best fit position
	ll1 = np.zeros(l2.shape,dtype=np.uint8)
	ll1[bf:bf+l1.shape[0]] = l1
	ll2 = np.zeros(l2.shape,dtype=np.uint8)
	ll2[0:l2.shape[0]] = l2
	if len(sr1) > len(sr2):
		overlayedLines = ovlLine(ll2, ll1)
	else:
		overlayedLines = ovlLine(ll1, ll2)
	ll1 = dolib.distanceitk(ll1)
	ll2 = dolib.distanceitk(ll2)
	return overlayedLines, (abs(horizPosErr), ovlaps[bf], np.average(abs(ll1-ll2)), np.max(abs(ll1-ll2)))

def lineIndexPage(iarray0, iarray1):
	"""
	compute similarity measures for each page line, compute statistics and return it in a string form
	"""
	# crop the first image and segment it to lines
	(ystart0, xstart0), (ystop0, xstop0) = getBBox(iarray0)
	itrim0 = iarray0[ystart0:ystop0, xstart0:xstop0].astype(np.uint8)
	tx0, sp0 = dolib.GetLineSegments(itrim0)
	
	# crop the second image and segment it to lines
	(ystart1, xstart1), (ystop1, xstop1) = getBBox(iarray1)
	itrim1 = iarray1[ystart1:ystop1, xstart1:xstop1].astype(np.uint8)
	tx1, sp1 = dolib.GetLineSegments(itrim1)

        #ipdb.set_trace()
        # detect merged lines in one set and merge them in the other
        while len(tx0) != len(tx1):
            tx0, sp0, tx1, sp1, corr = identMerged(tx0, sp0, tx1, sp1)
            if not corr: break
        #ipdb.set_trace()

        # create arrays with aligned lines
	vh_lines=[] # horizontally aligned lines
	v_lines=[]  # original lines from iarray1
	indices=[]
	for i in range(min(len(tx0),len(tx1))):
	    l0= dolib.GetLine(itrim0, tx0, i)
            l1 = dolib.GetLine(itrim1, tx1, i)
            #ipdb.set_trace()
	    #cline, ind = dolib.alignLineIndex(l0, l1)
	    cline, ind = alignLineIndex(l0, l1)
	    #cline, ind = dolib.alignLineIndex(dolib.GetLine(itrim0, tx0, i), dolib.GetLine(itrim1, tx1, i))
            #print ind
	    vh_lines.append(cline)
	    indices.append(ind)
	    #cline, ind = dolib.alignLineIndex(dolib.GetLine(itrim0, tx0, i), dolib.GetLine(itrim1, tx1, i), halign=False)
	    cline, ind = alignLineIndex(dolib.GetLine(itrim0, tx0, i), dolib.GetLine(itrim1, tx1, i), halign=False)
	    v_lines.append(cline)
	indices = np.array(indices)

	#create a page view to display vertically and horizontally adjusted overlays, taking line spaces from the source (first) page
        # height of the output page: sum of overlayed blobs + sum of spaces from image 1
        outheight = ystart0 + sum([b.shape[0] for b in vh_lines])+ sum(np.array(sp0)[:,1]) 
	vh_page = np.zeros((outheight, iarray0.shape[1], 3), dtype=np.uint8)
	vh_page[:] = 1

        # create page of horizontally aligned lines
	ar=ystart0	#the actual row
	for i in range(min(len(tx0),len(tx1))-1):
		vh_page[ar:ar+vh_lines[i].shape[0],xstart0:xstart0+vh_lines[i].shape[1]] = vh_lines[i]
		ar += vh_lines[i].shape[0] + sp0[i][1]
        #ipdb.set_trace()

	#create a page view to display vertically adjusted overlays, taking line spaces from the source (first) page
        # height of the output page: sum of overlayed blobs + sum of spaces from image 1
        outheight = ystart0 + sum([b.shape[0] for b in v_lines])+ sum(np.array(sp0)[:,1]) 
	v_page = np.zeros((outheight, iarray0.shape[1], 3), dtype=np.uint8)
	v_page[:] = 1

        # create page of the original lines from iarray1
	ar=ystart0	#the actual row
	for i in range(min(len(tx0),len(tx1))-1):
		v_page[ar:ar+v_lines[i].shape[0],xstart0:xstart0+v_lines[i].shape[1]] = v_lines[i]
		ar += v_lines[i].shape[0] + sp0[i][1]

	#height error in pixels
	heightErr=abs(float(itrim0.shape[0]-itrim1.shape[0]))
	#normalized height error in pixels
	heightErr = heightErr * (dpi*a4height/i2mm)/float(itrim0.shape[0]+itrim1.shape[0])

	#If changing the rslt format, adjust the gentestviews.sh script accordingly
        #linerslt = 'LinePixelOverlayIndex[%%]: %2.1f | FeatureDistanceError[mm]: %2.1f | LinePositionError[mm]: %2.2f |'
	#linerslt = linerslt%(100*np.average(indices[:,1]), px2mm(np.max(indices[:,3])),px2mm(np.max(indices[:,0]))) 
        linersltDist = 'FeatureDistanceError[mm]: %2.1f '
	linersltDist = linersltDist%(px2mm(np.max(indices[:,3])))
        linersltHPos = 'HorizLinePositionError[mm]: %2.2f '
	linersltHPos = linersltHPos%(px2mm(np.max(indices[:,0]))) 
	pagerslt = ' TextHeightError[mm]: %2.2f | LineNumDifference: %2d'
	pagerslt = pagerslt%((px2mm(heightErr), len(tx1)-len(tx0)))

        #ipdb.set_trace()
	return 1-vh_page, 1-v_page, linersltDist, linersltHPos, pagerslt

def annotateImg(img, color, size, position, text):
    cv2.putText(img, text, position, cv2.FONT_HERSHEY_PLAIN, size, color, thickness = 2)
    return img

def mergeSide(img1, img2):
    ''' place two images side-by-side'''
    offset=10
    ishape = img1.shape
    nshape=(img1.shape[0], 2*img1.shape[1]+offset, 3) #shape for numpy
    big=np.zeros(nshape, dtype=np.uint8)
    big[:ishape[0],:ishape[1]]=img1
    big[:ishape[0],ishape[1]+offset:]=img2
    return big

def genside (img1, img2, height, width, name1, name2, txt1, txt2):
	"""
	create a side-by-side view
	img1, img2: images
	name1, name2: their names 
	txt1, txt2: some text
	"""
        if len(img1.shape)==2:
            cimg1 = np.zeros((img1.shape[0], img1.shape[1], 3), dtype=np.uint8)
            cimg1[...,0] = img1
            cimg1[...,1] = img1
            cimg1[...,2] = img1
        else:
            cimg1 = img1
        if len(img2.shape)==2:
            cimg2 = np.zeros((img2.shape[0], img2.shape[1], 3), dtype=np.uint8)
            cimg2[...,0] = img2
            cimg2[...,1] = img2
            cimg2[...,2] = img2
        else:
            cimg2 = img2

	if annotated:
		cimg1=annotateImg(cimg1, (0,0,255), 2, (100, 70), 'Source: '+name1)
		#cimg1=annotateImg(cimg1, (0,0,255), 2, (100, 130), txt1)
		cimg2=annotateImg(cimg2, (0,0,255), 2, (100, 70), 'Target: '+name2)
		#cimg2=annotateImg(cimg2, (0,0,255), 2, (100, 130), txt2)
        cimg = mergeSide(cimg1, cimg2)
	if annotated:
	    cimg=annotateImg(cimg, (0,255,0), 2, (100, 130), txt1)
        return cimg

def genoverlay(img1, title, name1, name2, stattxt, img2=None):
	"""
	create an overlayed view
	img1, img2: images
	title: kind of title to print
	name1, name2: their names 
	txt: text to print below the title
	"""

	if img2 == None:
		outimg = 255*(1-img1)
	else:
                outimg=np.zeros((img1.shape[0], img1.shape[1], 3), dtype=np.uint8)
                outimg[...,0] = (255*(1-img1))
                outimg[...,1] = (255*(1-img2))
                outimg[...,2] = (255*(1-img2))
	if annotated:
	        outimg = annotateImg(outimg, (0, 0, 255), 2, (100, 50), title)
		txt = "cyan: %s"%name1
	        outimg = annotateImg(outimg, (0, 255, 255), 2, (100, 80), txt)
		txt = "red: %s"%name2
	        outimg = annotateImg(outimg, (255, 0, 0), 2, (100, 110), txt)
		#outimg=annotateImg(outimg, 'blue', mm2px(4), mm2px(4), txt)
	        outimg = annotateImg(outimg, (0, 0, 255), 1.3, (100, 140), stattxt)
	return outimg

def addPageLines(outimg, shapes):
    if len(shapes) > 1:
        pos=0
        for s in shapes:
            outimg[pos:pos+1,...]=0 
            pos += s[0]
    return outimg

def mm2px(val):
	"""
	convert 'val' im mm to pixels
	"""
	global dpi, i2mm
	return int(val*dpi/i2mm)
#
	
def getBBox(img1, img2=None):
	"""
	get a bounding box of nonzero pixels of one or two images
	"""
	if img2 == None:
		B = np.argwhere(255-img1)
		if B.shape[0] == 0:
			return (0,0),(0,0)
		return B.min(0), B.max(0) + 3
	else:
		min1, max1 = getBBox(img1)
		min2, max2 = getBBox(img2)
		return np.minimum(min1, min2), np.maximum(max1, max2)

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
	print "\t-o ................ file to store output view to {default:"+outfile+'}'
	#print "\t-p ................ report the results of individual pages {default: whole document}"
	#print "\t-fp ............... use only the first page {default: all pages}"
	print "\t-d ................ resolution of the converted pdf documen {default: "+str(dpi)+"}"
	print "\t-a ................ annotate each page with file name {default: no annotation}"
	print "\t-s ................ side-by-side pages {default: all}"
	print "\t-p ................ page overlay without alignment {default: all}"
	print "\t-l ................ page overlay with vertical line alignment {default: all}"
	print "\t-z ................ page overlay with vertical and horizontal line alignment {default: all}"
	print "\t-v ................ be verbose"
	print "\t-h ................ this usage"

def parsecmd(desc):
	global verbose, dpi, Names, annotated, overlayStyle, outfile
	try:
		opts, Names = getopt.getopt(sys.argv[1:], "hvalpszo:d:", ["help", "verbose"])
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
		elif o in ("-s"):
			overlayStyle = 's'  #side-by-side
		elif o in ("-p"):
			overlayStyle = 'p'  #page overlay, no alighment
		elif o in ("-l"):
			overlayStyle = 'l'  #page overlay, vertical line alignment
		elif o in ("-z"):
			overlayStyle = 'z'  #page overlay, vertical and horizontal line alignment
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
overlayStyle = 'a'  #output all versions by default
progdesc="Compare two pdf documents and return some statistics"
verbose = False
outfile = "paircmp.pdf"
dpi = 200
parsecmd(progdesc)
if Names == []:
	usage(progdesc)
	sys.exit(1)

exifcmd = 'exiftool -overwrite_original -Custom1="%s" %s >/dev/null'

# get rid of extension, if there is one
if outfile[-4:] == '.pdf':
    outfile = outfile[:-4]
try:
        #load documents
	pages1, shapes1 = pdf2array(Names[0], dpi)
        if pages1 == None:
            raise dolib.DoException("failed to open %s."%(Names[0]))
	pages2, shapes2 = pdf2array(Names[1], dpi)
        if pages2 == None:
            img1 = makeSingle(pages1, shapes1)
	    outimg = genoverlay(dolib.toBin(img1), "File '%s' cannot be loaded, test failed"%(Names[1]), Names[0], Names[1], "")
            Image.fromarray(outimg).save(outfile+'-p.pdf')
            rsltText="-:-:-:-:-:-:-:-:-:open"  #dummy resupl sting 10 dashes necessary
	    os.system(exifcmd%(rsltText, outfile+'-p.pdf'))
            Image.fromarray(outimg).save(outfile+'-l.pdf')
	    os.system(exifcmd%(rsltText, outfile+'-l.pdf'))
            Image.fromarray(outimg).save(outfile+'-z.pdf')
	    os.system(exifcmd%(rsltText, outfile+'-z.pdf'))
            Image.fromarray(outimg).save(outfile+'-s.pdf')
	    os.system(exifcmd%(rsltText, outfile+'-s.pdf'))
            raise dolib.DoException("failed to open %s."%(Names[1]))

        #ipdb.set_trace()
        shapes = [(min(a[0],b[0]),min(a[1],b[1])) for a,b in zip(shapes1, shapes2)] 
        # create single image for each
        npages = min(len(pages1), len(pages2))
        img1 = makeSingle(pages1, shapes)
        img2 = makeSingle(pages2, shapes)

	start, stop = getBBox(img2)
        if not (np.array(start) != np.array(stop)).any():
	    outimg = genoverlay(dolib.toBin(img1), "File '%s' is empty, test failed"%(Names[1]), Names[0], Names[1], "")
            Image.fromarray(outimg).save(outfile+'-p.pdf')
            rsltText="-:-:-:-:-:-:-:-:-:empty"  #dummy resupl sting 10 dashes necessary
	    os.system(exifcmd%(rsltText, outfile+'-p.pdf'))
            Image.fromarray(outimg).save(outfile+'-l.pdf')
	    os.system(exifcmd%(rsltText, outfile+'-l.pdf'))
            Image.fromarray(outimg).save(outfile+'-z.pdf')
	    os.system(exifcmd%(rsltText, outfile+'-z.pdf'))
            Image.fromarray(outimg).save(outfile+'-s.pdf')
	    os.system(exifcmd%(rsltText, outfile+'-s.pdf'))
            raise dolib.DoException("File %s is empty"%(Names[1]))

	#crop to common size 
	s1 = img1.shape
	s2 = img2.shape
	s=np.minimum(s1,s2)
	img1 = img1[:s[0],:s[1]]
	img2 = img2[:s[0],:s[1]]

	plainOvlRslt = getPagePixelOverlayIndex(dolib.toBin(img1), dolib.toBin(img2))
	lineVHOvlPage, lineVOvlPage, lineOvlDistRslt, lineOvlHPosRslt, pageHeightRslt = lineIndexPage(dolib.toBin(img1), dolib.toBin(img2))
	rsltText = plainOvlRslt+lineOvlDistRslt+ ' | ' +lineOvlHPosRslt+' | '+pageHeightRslt
	rsltText = rsltText.replace('|',':')
        # command to write statistics to the pdf file, to be used in report creation

        #options: s, p, l z
	if overlayStyle == 'p' or overlayStyle == 'a':
	    outimg = genoverlay(dolib.toBin(img1), 'Page overlay, no line alignment', Names[0], Names[1], plainOvlRslt+pageHeightRslt, img2=dolib.toBin(img2)) 
            addPageLines(outimg, shapes)
            Image.fromarray(outimg).save(outfile+'-p.pdf')
	    os.system(exifcmd%(rsltText, outfile+'-p.pdf'))
	if overlayStyle == 'l' or overlayStyle == 'a':
	    outimg = genoverlay(lineVOvlPage, 'Page overlay, vertically aligned lines', Names[0], Names[1], lineOvlHPosRslt)
            addPageLines(outimg, shapes)
            Image.fromarray(outimg).save(outfile+'-l.pdf')
	    os.system(exifcmd%(rsltText, outfile+'-l.pdf'))
	if overlayStyle == 'z' or overlayStyle == 'a':
	    outimg = genoverlay(lineVHOvlPage, 'Page overlay, vertically and horizontally aligned lines', Names[0], Names[1], lineOvlDistRslt)
            addPageLines(outimg, shapes)
            Image.fromarray(outimg).save(outfile+'-z.pdf')
	    os.system(exifcmd%(rsltText, outfile+'-z.pdf'))
	if overlayStyle == 's' or overlayStyle == 'a':
	    outimg=genside(img1, img2, s[0], s[1], Names[0], Names[1], rsltText.replace('*',' '), '')
            addPageLines(outimg, shapes)
            Image.fromarray(outimg).save(outfile+'-s.pdf')
	    os.system(exifcmd%(rsltText, outfile+'-s.pdf'))

except dolib.DoException, e:
	sys.stderr.write(e.what+" ("+Names[0]+", "+Names[1]+")\n")
	print e.what+" ("+Names[0]+", "+Names[1]+")"

