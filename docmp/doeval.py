#
# doeval.py v1.0 - 2013-09-30
#
# This script generates a report from alist of csv files with numeric evaluations and from printed document files
#
# Copyright (C) 2013 Milos Sramek <milos.sramek@soit.sk>
# Licensed under the GNU LGPL v3 - http://www.gnu.org/licenses/gpl.html
# - or any later version.
#
import numpy as np
import sys, os, getopt 
import csv
import SimpleITK as sitk
import dolib
import ipdb
#ipdb.set_trace()

from odf.opendocument import OpenDocumentText
from odf.text import P, H, A, S, List, ListItem, ListStyle, ListLevelStyleBullet, ListLevelStyleNumber, ListLevelStyleBullet, Span, Title
from odf.style import Style, TextProperties, ParagraphProperties, ListLevelProperties, FontFace,GraphicProperties, TableCellProperties
from odf.table import Table, TableColumn, TableRow, TableCell
from odf.draw import Frame, Image


class MyException(Exception):
	def __init__(self, what):
		self.what = what

def usage(desc):
	print sys.argv[0]+':',  desc, ofname
	print "Usage: ", sys.argv[0], "[options]", "rslt.csv"
	print "\t-o outfile ........ report {default: "+ofname+"}"
	print "\t-a ................ list of applications to include in report {all}"
	print "\t-c ................ include details about conversion of individual documents"
	#print "\t-e ................ include verifications"
	print "\t-r ................ show average grades in summaries {show only worst grades}"
	print "\t-l ................ display document lines with poor feature distance error (slow)"
	print "\t-v ................ be verbose"
	print "\t-p url ............ url of the location the pair pdf file will be (manually) copied to"
	print "\t-h ................ this usage"

def parsecmd(desc):
	global verbose, Names, useapps, repFC, repVer, repLineOvls, ofname, lpath, showAverages
	try:
		opts, Names = getopt.getopt(sys.argv[1:], "hvp:o:cela:r", ["help", "verbose"])
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
		elif o in ("-c"): repFC=True
		elif o in ("-r"): showAverages=True
		elif o in ("-e"): repVer=True
		elif o in ("-l"): repLineOvls=True
		elif o in ("-o"):
			ofname = a
		elif o in ("-p"):
			lpath = a
		elif o in ("-a"):
			useapps = a.split()
		else:
			assert False, "unhandled option"

def loadCSV(csvfile):
	""" Load the results
	Retuns: ID list of ints, ROI (array) of strings
	"""
	# get information about the slices first
	with open(csvfile, 'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quoting=csv.QUOTE_NONE)
		values = {}
		for row in reader:
			#ipdb.set_trace()
			if(reader.line_num == 1): 
				h = [row[i].strip() for i in range(len(row))]
				#strip the trailing empty items
				hlen = len(h)
				h.append('')
				last = h.index('')
				h = h[:last]
			else:
				case = row[h.index('Test case')].strip()
				fmt = row[h.index('Format')].strip()
				pair = row[h.index('View pair file')].strip()
				#find the first empty field
				if(len(row) < hlen):
					values[(row[h.index('Source app')].strip(),row[h.index('Target app')].strip())] = None
				else:
					numpart=row[h.index('Target app')+1:last]
					#print numpart
					#cvt=[float(numpart[i]) for i in range(len(numpart))]
					cvt = []
					error = False
					for i in range(len(numpart)):
						if numpart[i].find('Error') >= 0:
							#ipdb.set_trace()
							error = True
							break
						else:
							cvt.append(float(numpart[i]))
					if error:
						values[(row[h.index('Source app')].strip(),row[h.index('Target app')].strip())] = (None, pair)
					else:
						values[(row[h.index('Source app')].strip(),row[h.index('Target app')].strip())] = (cvt, pair)


	print csvfile
	return case, fmt, h[h.index('Target app')+1:], values


def pairs(v):
	"""
	return all tuples defined by combination of v
	"""
	p=[]
	for i in v:
		for j in v:p.append((i,j))
	return p

def GetGradeInd(data):
	""" get grade for individual observed measures
	"""
	global mdInd, phInd, hsInd, ldInd
	global mdMax, phMax, hsMax, ldMax
	dd = data[0] #list of measures is at [0], [1] is the pair file name
	#if dd == None: return np.array((len(mdMax),len(mdMax),len(mdMax),len(mdMax)))
	if dd == None: return np.array((0,0,0,0))
	md = len(mdMax)
	for i in range(len(mdMax)):
		if mdMax[i] > dd[mdInd]:
			md = i
			break
	ph = len(phMax)
	for i in range(len(phMax)):
		if phMax[i] > dd[phInd]:
			ph = i
			break
	hs = len(hsMax)
	for i in range(len(hsMax)):
		if hsMax[i] > dd[hsInd]:
			hs = i
			break
	ld = len(ldMax)
	for i in range(len(ldMax)):
		if ldMax[i] > abs(dd[ldInd]):
			ld = i
			break
	return ph, md, hs, ld

def isindep(app1, app2):
	indep = { 
			'LO':['MS','AW','GD','CW'], 
			'AO':['MS','AW','GD','CW'], 
			'OO':['MS','AW','GD','CW'],
			'MS':['AO','LO','OO','GD','AW','CW'], 
			'GD':['AO','LO','OO','MS','AW','CW'], 
			'AW':['AO','LO','OO','MS','GD','CW'],
			'CW':['AO','LO','OO','MS','GD','AW']
		}
	return app1[:2] in indep[app2[:2]] 

def GetIndApps(app, values):
	indeps=[]
	for pair in values.keys(): 
		if app==pair[0] and isindep(pair[0], pair[1]):
			indeps.append(pair)
	return indeps

def add2dict(dic, ind, sval):
	if dic.has_key(ind):
		dic[ind] = dic[ind]+' '+sval
	else:
		dic[ind] = sval

def pdfpaths(case, fmt, a1, a2):
	"""
	reconstruct paths of source and target pdf files
	"""
	global native
	s='/'
	t='.'
	d='-'
	#ipdb.set_trace()
	source = case+s+a1+s+case+d+a1+t+native[a1]+t+a1+t+'pdf'
	target = case+s+a1+s+case+d+a1+t+fmt+t+a2+t+'pdf'
	return source, target

def createTable(name, tbl, links=False):
	""" Create table from the 2D array tbl
	"""
	table = Table(name=name)
	table.addElement(TableColumn(numbercolumnsrepeated=str(len(tbl[0]))))

	# table header
	tr = TableRow()
	table.addElement(tr)
	for i in range(len(tbl[0])):
		tc = TableCell(valuetype="string", stylename='TTstyle')
		tc.addElement(P(text=tbl[0][i], stylename='CBstyle'))
		tr.addElement(tc)
	# content
	for r in range(1,len(tbl)):
		tr = TableRow()
		table.addElement(tr)
		for c in range(len(tbl[0])):
			tc = TableCell(valuetype="string", stylename='TTstyle')
			if c==0:
				tc.addElement(P(text=tbl[r][c], stylename='CBstyle'))
			else:
				v = tbl[r][c]
				if isinstance(v,float): 
					tc.addElement(P(text='%2.1f'%v, stylename='C'+str(int(v))+'style'))
				else:
					tc.addElement(P(text=v))
			tr.addElement(tc)
	return table

def createFmtCaseTable(rsltTab, fmpair, apps, name='table'):
	"""
	Create app x app table for a given fmpair = (fmt,case) pair
	"""
	rt = rsltTab[fmpair]
	hdr=[]
	for i in range(len(apps)): hdr.append(apps[i])
	#tbl=[['%s/%s'%(fmpair[0],fmpair[1])]+hdr]
	tbl=[['src/tgt']+hdr]
	for i in range(len(apps)):
		l = [apps[i]]
		for j in range(len(apps)):
			akey = (apps[i], apps[j])
			if rt.has_key(akey):
				lll=[]
				for v in rt[akey][0]: lll.append((v))
				ll=(lll,rt[akey][1])
			else:
				ll='-'
			l.append(ll)
		tbl.append(l)
	return createTableWithLinks(name, tbl)

def createAvgTable(rsltTab, apps, name='table', fmt=None, case=None, sumMethod='avg'):
	mmm= getAppAvg(rsltTab, apps, fmt=fmt, case=case, sumMethod=sumMethod)
	hdr=[]
	for i in range(len(apps)): hdr.append(apps[i])
	tbl=[['src/tgt']+hdr]
	for i in range(len(apps)):
		l = [apps[i]]
		for j in range(len(apps)):
			ll=[]
			v = mmm[(apps[i], apps[j])]
			if np.isnan(v):
				l.append('-')
			else:
				l.append(float('%2.1f'%v))
		tbl.append(l)
	return createTable(name, tbl)

def getAppAvg(rsltTab, apps, fmt=None, case=None, sumMethod='avg'):
	"""
	get averages for specified cases and formats, or for everything
	"""

	rslt={}
	for i in range(len(apps)):
		for j in range(len(apps)):
			em=np.zeros((0,4))	#4: number of observer error measures
			for casefmt in rsltTab.keys():
				if rsltTab[casefmt].has_key((apps[i], apps[j])):
					v = rsltTab[casefmt][(apps[i], apps[j])][0]
					addIt = (fmt != None and fmt == casefmt[1]) 
					addIt = addIt or (case != None and case == casefmt[0]) 
					addIt = addIt or (case == None and fmt == None) 
					if addIt:
						em=np.resize(em,(em.shape[0]+1,4))
						em[-1] = np.array(v)
			if len(em) > 0:
				if sumMethod=='avg':
					rval = np.average(em)
				elif sumMethod=='max':
					rval = np.max(em)
				elif sumMethod=='med':
					rval = np.median(em)
			else:
				rval = np.nan
			rslt[(apps[i], apps[j])] = rval
	return rslt

def createTableWithLinks(name, tbl, ):
	""" Create table from the 2D array tbl
	"""
	table = Table(name=name)
	table.addElement(TableColumn(numbercolumnsrepeated=str(len(tbl))))

	# table header
	tr = TableRow()
	table.addElement(tr)
	for i in range(len(tbl[0])):
		tc = TableCell(valuetype="string", stylename='TTstyle')
		tc.addElement(P(text=tbl[0][i], stylename='CBstyle'))
		tr.addElement(tc)
	# content
	for r in range(1,len(tbl[0])):
		tr = TableRow()
		table.addElement(tr)
		for c in range(len(tbl[0])):
			tc = TableCell(valuetype="string", stylename='TTstyle')
			if c==0:
				tc.addElement(P(text=tbl[r][c], stylename='CBstyle'))
			else:
				v= tbl[r][c]
				if v == '-':
					tc.addElement(P(text=v))
				else:
					#ipdb.set_trace()
					p = P()
					if isinstance(v,tuple): 
					    w=np.max(np.array(v[0]))
					    p=P(stylename='C'+str(int(w))+'style')
                                            labels='pzls'
                                            for i in range(4):
					        link = A(type="simple",href=lpath+str(v[1]).replace("-s-","-"+labels[i]+"-"), text=str(v[0][i]))
					        p.addElement(link)
					        p.addText(" ")
					else:
					    p.addText(str(v[0])+ " ( ")
					    link = A(type="simple",href=lpath+str(v[1]), text="S")
					    p.addElement(link)
					    p.addText(" ")
					    link = A(type="simple",href=lpath+str(v[1]).replace("-s-","-p-"), text="P")
					    p.addElement(link)
					    p.addText(" ")
					    link = A(type="simple",href=lpath+str(v[1]).replace("-s-","-l-"), text="L")
					    p.addElement(link)
					    p.addText(" )")
					tc.addElement(p)
			tr.addElement(tc)
	return table

def getFmtCaseAvg(rsltTab, apps, fmt=None, case=None, sumMethod='avg'):
	"""
	get averages for specified cases and formats, or for everything
	"""
	em=np.zeros((0,4))	#4: number of observer error measures
	for casefmt in rsltTab.keys():
		for i in range(len(apps)):
			for j in range(len(apps)):
				if rsltTab[casefmt].has_key((apps[i], apps[j])):
					v = rsltTab[casefmt][(apps[i], apps[j])][0]
					addIt = (fmt == casefmt[1]) 
					addIt = addIt or (case == casefmt[0]) 
					addIt = addIt or (case == None and fmt == None) 
					if addIt:
						em=np.resize(em,(em.shape[0]+1,4))
						em[-1] = np.array(v)
					#print casefmt, v
	#ipdb.set_trace()
	if sumMethod=='avg':
		retval = np.average(em, axis=0).tolist()
	elif sumMethod=='max':
		retval = np.max(em, axis=0).tolist()
	elif sumMethod=='med':
		retval = np.median(em, axis=0).tolist()
	return retval

def createImage(text, img_path, sx, sy):
	p = P(text=text)
	href = textdoc.addPicture(img_path)
	#f = Frame(name="graphics1", anchortype="paragraph", width="5in", height="6.6665in", zindex="0")
	f = Frame(name="graphics1", anchortype="as-char", width=str(sx)+"mm", height=str(sy)+"mm", zindex="0")
	p.addElement(f)
	img = Image(href=href, type="simple", show="embed", actuate="onLoad")
	f.addElement(img)
	return p

def getWorstLine(name0, name1):
	"""
	find the worst line in the document pair, save it and return the name
	"""
	global errormeasures, filestodelete
	dpi=96	#if 192 is used, images appear in the odt file with 100% magnification
	img0 = dolib.pdf2array(name0, 2*dpi)
	img1 = dolib.pdf2array(name1, 2*dpi)
	img0 = dolib.toBin(img0)
	img1 = dolib.toBin(img1)

	# if multiplied by 2, the final images have magnification 100%. Funny, isn't it?
	pxsize = 2*dolib.a4height()/img0.shape[0]

	# crop the first image and segment it to lines
	(ystart0, xstart0), (ystop0, xstop0) = dolib.getBBox(img0)
	itrim0 = img0[ystart0:ystop0, xstart0:xstop0].astype(np.uint8)
	tx0, sp0 = dolib.GetLineSegments(itrim0)
	
	# crop the second image and segment it to lines
	(ystart1, xstart1), (ystop1, xstop1) = dolib.getBBox(img1)
	itrim1 = img1[ystart1:ystop1, xstart1:xstop1].astype(np.uint8)
	tx1, sp1 = dolib.GetLineSegments(itrim1)

	worstline = None
	worstindex = -1
	for i in range(min(len(tx0), len(tx1))):
		cline, ind = dolib.alignLineIndex(dolib.GetLine(itrim0, tx0, i), dolib.GetLine(itrim1, tx1, i))
		if ind[3] > worstindex:
			worstline = cline
			worstindex = ind[3]
	tn = dolib.tmpname()+'.png'
	filestodelete.append(tn)
	sitk.WriteImage(sitk.GetImageFromArray(255*worstline.astype(np.uint8), isVector=True), tn)
	return tn, dolib.px2mm(worstline.shape[1], dpi), dolib.px2mm(worstline.shape[0],dpi), dolib.px2mm(worstindex,dpi), len(tx1) - len(tx0)

def reportFmtCase(textdoc, rstlTab, apps, fmtcase):
	#build the table
	l=['source / target']
	
	#textdoc.text.addElement(H(outlinelevel=3,text='Grading of file conversions'))
	text = "The source and target test documents for the '%s' test case and the '%s' format were converted to pdf. "%(fmtcase[0], fmtcase[1])
	text+= "Both pdf files were then compared and graded. The grades span from '0' (identical) to '5' (very very bad)"
	textdoc.text.addElement(P(text=text))
	textdoc.text.addElement(P(text=' '))
	textdoc.text.addElement(createFmtCaseTable(rsltTab, fmtcase, apps, name='table'))
	textdoc.text.addElement(P(text=' '))
        text = "Meaning of grades from left: %s. "%str(errormeasures)
	text+= "The hyperlinks point different views of the printed source and target documents, "
        text+= "which reflect the problem best. "
        text+= "If the leftmost view is too messy, see the rightmost side-by-side view. "

	textdoc.text.addElement(P(text=text))

def reportVerification(textdoc, rsltTab, fmtcase):
	# select applications which read correctly their own files and check, 
	# if a confirming independent application exists
	vvv=rsltTab[fmtcase]
	for appPair in vvv.keys(): 
		if(appPair[0] == appPair[1]): #
			# find applications, which read 
			if max(vvv[appPair][0]) < 3:
				for indep in GetIndApps(appPair[0], vvv):
					l = max(vvv[indep][0])
					#ipdb.set_trace()
					if l < 3 :
						add2dict(vwrite, (case, fmt, indep[0]), indep[1]+'('+str(l)+') ')
						add2dict(vread, (case, fmt, indep[1]), indep[0]+'('+str(l)+') ')
	
	# verification list
	textdoc.text.addElement(H(outlinelevel=3,text='Verifications'))
	text = "If two or more independent applications can read and display (print) a file identically, we may assume that the source (target) application can write (read) files in the given format correctly."
	textdoc.text.addElement(P(text=text))
	text = "The results are presented along with the fidelity grade."
	textdoc.text.addElement(P(text=text))
	textdoc.text.addElement(H(outlinelevel=4,text='Read verifications'))
	for k,v in vread.iteritems():
		textdoc.text.addElement(P(text='Reading '+str(k[2])+' verified by '+str(v)))
	textdoc.text.addElement(H(outlinelevel=4,text='Write verifications'))
	for k,v in vwrite.iteritems():
		textdoc.text.addElement(P(text='Writing '+str(k[2])+' verified by '+str(v)))

def reportLineOvls(textdoc, rsltTab, fmtcase):
	# show the worst line overlays
	vvv=rsltTab[fmtcase]
	textdoc.text.addElement(H(outlinelevel=3,text='A detailed view of lines with poor feature distance grade'))
	text = "If the feature distance grade for a document pair is 2 and worse, the line with the worst grade is shown here to get an idea of the mismatch severity."
	textdoc.text.addElement(P(text=text))
	for pair in vvv.keys(): 
		fn1, fn2 = pdfpaths(fmtcase[0], fmtcase[1], pair[0], pair[1])	
		if vvv[pair][0][1] > 1:
			#ipdb.set_trace()
			imgfile, sx, sy, error, mislines = getWorstLine(fn1, fn2)
			text='A document written in the %s format by %s and read back by %s. '%(fmtcase[1], pair[0],pair[1])
			text+='Cyan: %s, red: %s, black: both. '%(pair[0],pair[1])
			text+='Grade: '+str(vvv[pair][0][1])
			textdoc.text.addElement(P(text=' '))
			textdoc.text.addElement(P(text=text))
			textdoc.text.addElement(createImage('', imgfile, sx, sy))
			#os.unlink(imgfile)

def addStyles(textdoc):
	s = textdoc.styles
	StandardStyle = Style(name="Standard", family="paragraph")
	s.addElement(StandardStyle)

	C0 = Style(name="C0style",family="paragraph", parentstylename='Standard', displayname="Color style 0")
	C0.addElement(ParagraphProperties(backgroundcolor="#00FF00"))
	s.addElement(C0)

	C1 = Style(name="C1style",family="paragraph", parentstylename='Standard', displayname="Color style 1")
	C1.addElement(ParagraphProperties(backgroundcolor="#00FF00"))
	s.addElement(C1)

	C2 = Style(name="C2style",family="paragraph", parentstylename='Standard', displayname="Color style 2")
	C2.addElement(ParagraphProperties(backgroundcolor="#AAFF00"))
	s.addElement(C2)

	C3 = Style(name="C3style",family="paragraph", parentstylename='Standard', displayname="Color style 3")
	C3.addElement(ParagraphProperties(backgroundcolor="#FFFF00"))
	s.addElement(C3)

	C4 = Style(name="C4style",family="paragraph", parentstylename='Standard', displayname="Color style 4")
	C4.addElement(ParagraphProperties(backgroundcolor="#FFAA00"))
	s.addElement(C4)

	C5 = Style(name="C5style",family="paragraph", parentstylename='Standard', displayname="Color style 5")
	C5.addElement(ParagraphProperties(backgroundcolor="#FF0000"))
	s.addElement(C5)

	CB = Style(name="CBstyle",family="paragraph", parentstylename='Standard', displayname="Color style Blue")
	CB.addElement(ParagraphProperties(backgroundcolor="#AAAAFF"))
	s.addElement(CB)

	TT = Style(name="TTstyle",family="table-cell", parentstylename='Standard', displayname="Table style TT")
	TT.addElement(TableCellProperties(border="1pt solid #000000"))
	textdoc.automaticstyles.addElement(TT)

def showItems(textdoc, text, itemlist):
	for i in itemlist: text += i+' '
	textdoc.text.addElement(P(text=text))

#global definitions
native = {	# native formats
		'LO36':'odt', 'LO40':'odt', 'LO41':'odt', 'LO42':'odt', 
                'LO43':'odt', 'OO33':'odt', 'AO40':'odt', 'AO34':'odt',
	        'MS13':'docx', 'MS10':'docx', 'MS07':'docx', }
progdesc='Derive some results from pdf tests'
verbose = False
repFC=False
repVer=False
repLineOvls=False
useapps=None
sumMethod='avg'
showAverages=False

mdMax = (0.01,0.5,1,2,4)	#0.5: difference of perfectly fitting AOO/LOO and MS document owing to different character rendering
phMax = (0.01,5,10,15,20)	# 
hsMax = (0.01,2, 4, 6,8)
ldMax = (0.01,0.01,0.01,0.01,0.01)
ofname= 'rslt'
# absolute path
lpath = 'file://'+os.getcwd()+'/'
# relative path 
lpath = '../'
#errormeasures=['TextHeightError', 'FeatureDistError', 'HorizLinePositionError', 'LineNumberDiff'] #the order is defined by the return value of the GetGradeInd function
errormeasures=['TextHeightError', 'FeatureDistError', 'HorizLinePosErr', 'LineNumberDiff'] #the order is defined by the return value of the GetGradeInd function

parsecmd(progdesc)
#ipdb.set_trace()
if Names == []:
	usage(progdesc)
	sys.exit(1)

rsltTab = {} 	# a hierarchic dictionary storing measures for the test cases
		# Organization: case -> fmt -> result tuple
fmtGrades = {} 	# fmt -> pair -> list of tuples
fmtLD = {} 	# case -> pair -> list of line differences
caseGrades = {} 	# fmt -> pair -> list of tuples
caseLD = {} 	# case -> pair -> list of line differences
filestodelete = []	#temporary files to delete after writing the report

# instantiate an ODF text document (odt)
textdoc = OpenDocumentText()
addStyles(textdoc)
Names.sort()
#read data from all csv files and build the rsltTab data structure
for fname in Names:
	#print
	#print fname
	case, fmt, csvhdr, values = loadCSV(fname)
	rsltTab[(case,fmt)] = {}
        #ipdb.set_trace()
	mdInd = csvhdr.index('FeatureDistanceError[mm]')
	phInd = csvhdr.index('TextHeightError[mm]')
	hsInd = csvhdr.index('HorizLinePositionError[mm]')
	ldInd = csvhdr.index('LineNumDifference')
	vread = {}	#verified read capability 
	vwrite = {} 	#verified Write capability
	# lists for three observed errorr measures

	# get actual list of applications
	apps=[]
	for k in values.keys():	
		if k[0] not in apps: apps.append(k[0])
		if k[1] not in apps: apps.append(k[1])
	apps.sort()
	if useapps:
		aux=[]
		for a in useapps:
			if a in apps: aux.append(a)
		apps = aux

	#build the result table
	for i in range(len(apps)):
		for j in range(len(apps)):
			if values.has_key((apps[i], apps[j])):
				grades = GetGradeInd(values[(apps[i], apps[j])])
				rsltTab[(case,fmt)][(apps[i], apps[j])] = (grades, values[(apps[i], apps[j])][1])
	
	#ipdb.set_trace()

# average measures for all cases and formats
# we report on the mdInd, phInd, hsInd and ldInd measures
#for casefmt in rsltTab.keys():
	#print rsltTab[casefmt][0]

# get actual list of formats and cases
formats=[]
cases=[]
for k in rsltTab.keys():	
	if k[1] not in formats: formats.append(k[1])
	if k[0] not in cases: cases.append(k[0])

#move 0033 to start, if exists
if apps[-1] == "OO33":
    apps.remove("OO33")
    apps = ["OO33"]+apps

# start writing the report

textdoc.text.addElement(P(text='Results of the "docmp" office document interoperability test', stylename="Heading"))
showItems(textdoc, "Tested document formats: ", formats)
showItems(textdoc, "Tested cases: ", cases)
showItems(textdoc, "Tested applications: ", apps)
textdoc.text.addElement(P(text=''))

text="In the preparation phase, for each test case a source document was created in the native format  (LO, AOO: odf, MS: OOXML) of each tested application. "
text += "In testing the following was performed for each test case:"
textdoc.text.addElement(P(text=text))
text = "  1. a source document was printed to pdf (source pdf) by its application"
textdoc.text.addElement(P(text=text))
text = "  2. a source document was converted to all remaining formats by its application"
textdoc.text.addElement(P(text=text))
text = "  3. all source and converted documents were printed to pdf (target pdfs) by all tested applications "
textdoc.text.addElement(P(text=text))
text = "  4. all pairs of a source pdf and related target pdfs were compared. Numeric error measures were computed and graded by grade 0 (identical)...5 (very very bad)."
textdoc.text.addElement(P(text=text))

hdr=errormeasures
# the text must reflect the errormeasures list
textdoc.text.addElement(P(text=' '))
text = "The following error measures are used in this report: "
textdoc.text.addElement(P(text=text))

textList = List()
item = ListItem()
text='TextHeightError: difference in height of the rendered text of the source and target pdf (in mm). '
text += 'The following thresholds were used for grading: %s mm.'%str(phMax)
item.addElement(P(text=text))
textList.addElement(item)
item = ListItem()
text='FeatureDistanceError: distance between differently rendered details of corresponding overlayed text lines of both documents , measured in mm. Example1:  if list bullets have different distance to the text, the measure reflects mutual distance of the bullets. Example 2: if different bullet characters are used, the measure reflects maximum distance between contours of both bullet shapes. '
text += 'The following thresholds were used for grading: %s mm.'%str(mdMax)
item.addElement(P(text=text))
textList.addElement(item)
textdoc.text.addElement(textList)
item = ListItem()
text='HorizLinePositionError: horizontal shift in mm required to achieve best match of the lines. '
text += 'The following thresholds were used for grading: %s mm.'%str(hsMax)
item.addElement(P(text=text))
textList.addElement(item)
item = ListItem()
text='LineNumberDiff: difference of the numbers of lines in both documents. Only two grades are used: 0 for equal number of lines, 5 for different.' 
item.addElement(P(text=text))
textList.addElement(item)
textdoc.text.addElement(textList)
text="Except for the numeric errors overlayed views of source/targer pdfs was created and is available through links in the tables below"
textdoc.text.addElement(P(text=' '))
textdoc.text.addElement(P(text=text))

text = "Summary for all tested cases and applications"
textdoc.text.addElement(H(outlinelevel=1,text=text))
showItems(textdoc, "Tested cases: ", cases)
showItems(textdoc, "Tested applications: ", apps)
textdoc.text.addElement(P(text=''))

if showAverages:
    text="Average grades:"
    textdoc.text.addElement(P(text=text))
    tbl=[['format']+hdr]
    for f in formats:
	l=[f]+ getFmtCaseAvg(rsltTab, apps, fmt=f,sumMethod='avg')
	tbl.append(l)
    textdoc.text.addElement(createTable('Table_all_cases', tbl))

text="Worst grades:"
textdoc.text.addElement(P(text=text))
tbl=[['format']+hdr]
for f in formats:
	l=[f]+ getFmtCaseAvg(rsltTab, apps, fmt=f,sumMethod='max')
	tbl.append(l)
textdoc.text.addElement(createTable('Table_all_cases', tbl))

text = "Summary for all tested formats and applications"
textdoc.text.addElement(H(outlinelevel=1,text=text))

showItems(textdoc, "Tested document formats: ", formats)
showItems(textdoc, "Tested applications: ", apps)
textdoc.text.addElement(P(text=''))

if showAverages:
    text="Average grades:"
    textdoc.text.addElement(P(text=text))
    tbl=[['case']+hdr]
    for c in cases:
	l=[c]+ getFmtCaseAvg(rsltTab, apps, case=c, sumMethod='avg')
	tbl.append(l)
    textdoc.text.addElement(createTable('Table_all_formats', tbl))

text="Worst grades:"
textdoc.text.addElement(P(text=text))
tbl=[['case']+hdr]
for c in cases:
	l=[c]+ getFmtCaseAvg(rsltTab, apps, case=c, sumMethod='max')
	tbl.append(l)
textdoc.text.addElement(createTable('Table_all_formats', tbl))

text = "Summary for the tested formats"
textdoc.text.addElement(H(outlinelevel=1,text=text))
for f in formats:
	text = "Summary for the %s format"%f
	textdoc.text.addElement(H(outlinelevel=2,text=text))
	showItems(textdoc, "Tested cases: ", cases)
	showItems(textdoc, "Tested applications: ", apps)
	textdoc.text.addElement(P(text=''))


        if showAverages:
	    text="Average grades:"
	    textdoc.text.addElement(P(text=text))
	    textdoc.text.addElement(createAvgTable(rsltTab, apps, fmt=f,sumMethod='avg',name='table_format_%s'%f))

	text="Worst grades:"
	textdoc.text.addElement(P(text=text))
	textdoc.text.addElement(createAvgTable(rsltTab, apps, fmt=f,sumMethod='max',name='table_format_%s'%f))
 	text = "Dash '-' means that the application was not used to create or convert source files. "
	textdoc.text.addElement(P(text=text))
	text="First column: source applications"
	textdoc.text.addElement(P(text=text))
	text="First row: target applications"
	textdoc.text.addElement(P(text=text))


fmtcasepairs=rsltTab.keys()
fmtcasepairs.sort()
for f in formats:
	text="Details for the %s format"%f
	textdoc.text.addElement(H(outlinelevel=1,text=text))
	for c in cases:
		text="The '%s' test case, the '%s' format"%(c,f)
                if repFC or repVer or repLineOvls:
		    textdoc.text.addElement(H(outlinelevel=2,text=text))
		if(repFC): reportFmtCase(textdoc, rsltTab, apps, (c,f))
		if(repVer): reportVerification(textdoc, rsltTab,  (c,f))
		if(repLineOvls): reportLineOvls(textdoc, rsltTab,  (c,f))

textdoc.save(ofname+'.odt')
for f in filestodelete: os.unlink(f)
