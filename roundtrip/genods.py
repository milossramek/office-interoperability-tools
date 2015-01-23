#! /usr/bin/python
#
# doeval.py v1.0 - 2013-09-30
#
# This script generates a report from alist of csv files with numeric evaluations and from printed document files
#
# Copyright (C) 2013 Milos Sramek <milos.sramek@soit.sk>
# Licensed under the GNU LGPL v3 - http://www.gnu.org/licenses/gpl.html
# - or any later version.
#
import sys, os, getopt 
import csv
import ipdb
from odf.opendocument import OpenDocumentSpreadsheet
from odf.style import Style, TextProperties, ParagraphProperties, TableColumnProperties, TableCellProperties
from odf.text import P, A
from odf.table import Table, TableColumn, TableRow, TableCell
from odf.office import Annotation

PWENC = "utf-8"

#ipdb.set_trace()

def usage(desc):
	print sys.argv[0]+':',  desc, ofname, ifname
	print "Usage: ", sys.argv[0], "[options]"
	print "\t-i infile ... ..... report {default: "+ifname+"}"
	print "\t-o outfile ........ report {default: "+ofname+"}"
	print "\t-a ................ list of applications to include in report {all}"
	print "\t-v ................ be verbose"
	print "\t-h ................ this usage"

def parsecmd(desc):
	global verbose, useapps, ofname, ifname
	try:
            opts, Names = getopt.getopt(sys.argv[1:], "hvi:o:a:", ["help", "verbose"])
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
		elif o in ("-o"):
			ofname = a
		elif o in ("-i"):
			ifname = a
		elif o in ("-a"):
			useapps = a.split()
		else:
			assert False, "unhandled option"

def loadCSV(csvfile):
	""" Load the results
	Retuns: ID list of ints, ROI (array) of strings
	"""
	# get information about the slices first
        vcnt=5  # we expect 5 error measures
        values = {}
	with open(csvfile, 'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quoting=csv.QUOTE_NONE)
		values = {}
		for row in reader:
			if(reader.line_num == 1): 
                            apps=[]
                            for i in range(len(row)):
                                if row[i] != '': apps.append(row[i])
                            apps = apps[1:]
                        elif(reader.line_num == 2): 
                            labels=row[1:vcnt+1]
                        elif(reader.line_num > 2): 
			    #ipdb.set_trace()#
                            d={}
                            for i in range(len(apps)):
                                d[apps[i]]=row[1+vcnt*i: 1+vcnt*(i+1)]
                            values[row[0]] = d
        return apps, labels, values 

#testLabelsShort=['PPOI','FDE', 'HLPE', 'THE', 'LND'] 
def valToGrade(data):
	""" get grade for individual observed measures
	"""
	global FDEMax, HLPEMax, THEMax, LNDMax
	#ipdb.set_trace()#
        if data[0] == "-":
            return [6,6,6,6]
        FDEVal=5
	for i in range(len(FDEMax)):
            if FDEMax[i] >float(data[0]):
		FDEVal=i
		break
        HLPEVal=5
	for i in range(len(HLPEMax)):
            if HLPEMax[i] > float(data[1]):
		HLPEVal=i
		break
        THEVal=5
	for i in range(len(THEMax)):
            if THEMax[i] > float(data[2]):
		THEVal=i
		break
        LNDVal=5
	for i in range(len(LNDMax)):
            if LNDMax[i] > abs(float(data[3])):
		LNDVal=i
		break
        return [FDEVal, HLPEVal, THEVal, LNDVal]

def addAnn(txt):
        ann=Annotation(width="10cm")
        annp = P(stylename=tablecontents,text=unicode(txt,PWENC))
        ann.addElement(annp)
        return ann

def addAnnL(txtlist):
        ann=Annotation(width="10cm")
        for t in txtlist:
            annp = P(stylename=tablecontents,text=unicode(t,PWENC))
            ann.addElement(annp)
        return ann

progdesc='Derive some results from pdf tests'
verbose = False
useapps=None

ifname= 'all.csv'
ofname= 'rslt.ods'

# we assume here this order in the testLabels list:[' PagePixelOvelayIndex[%]', ' FeatureDistanceError[mm]', ' HorizLinePositionError[mm]', ' TextHeightError[mm]', ' LineNumDifference'] 
testLabelsShort=['PPOI','FDE', 'HLPE', 'THE', 'LND'] 
testViewsExpl=[
    'Links to views corresponding left to right to the grades on the left. ' 
    'F: overlay of lines aligned verically and horizontally.', 
    'H: overlay of lines aligned only verically.', 
    'T: page overlay with no alignment.', 
    'L: side by side view.'] 


FDEMax = (0.01,0.5,1,2,4)	#0.5: difference of perfectly fitting AOO/LOO and MS document owing to different character rendering
HLPEMax = (0.01,5,10,15,20)	# 
THEMax = (0.01,2, 4, 6,8)
LNDMax = (0.01,0.01,0.01,0.01,0.01)
lpath = '../'

parsecmd(progdesc)
targetApps, testLabels, values = loadCSV(ifname)
print targetApps
#ipdb.set_trace()
textdoc = OpenDocumentSpreadsheet()

# Create automatic styles for the column widths.
# ODF Standard section 15.9.1
nameColStyle = Style(name="nameColStyle", family="table-column")
nameColStyle.addElement(TableColumnProperties(columnwidth="4cm"))
textdoc.automaticstyles.addElement(nameColStyle)

viewColStyle = Style(name="viewColStyle", family="table-column")
viewColStyle.addElement(TableColumnProperties(columnwidth="2cm"))
textdoc.automaticstyles.addElement(viewColStyle)

valColStyle = Style(name="valColStyle", family="table-column")
valColStyle.addElement(TableColumnProperties(columnwidth="1.1cm"))
valColStyle.addElement(ParagraphProperties(textalign="center")) #??
textdoc.automaticstyles.addElement(valColStyle)

# Create a style for the table content. One we can modify
# later in the word processor.
tablecontents = Style(name="Table Contents", family="paragraph")
tablecontents.addElement(ParagraphProperties(numberlines="false", linenumber="0"))
tablecontents.addElement(TextProperties(fontweight="bold"))
textdoc.styles.addElement(tablecontents)


TH = Style(name="THstyle",family="table-cell", parentstylename='Standard', displayname="Table Header")
#TH.addElement(TableCellProperties(backgroundcolor="#00FF00"))
TH.addElement(ParagraphProperties(textalign="center"))
textdoc.styles.addElement(TH)

C0 = Style(name="C0style",family="table-cell", parentstylename='Standard', displayname="Color style 0")
C0.addElement(TableCellProperties(backgroundcolor="#00FF00"))
C0.addElement(ParagraphProperties(textalign="center"))
textdoc.styles.addElement(C0)

C1 = Style(name="C1style",family="table-cell", parentstylename='Standard', displayname="Color style 1")
C1.addElement(TableCellProperties(backgroundcolor="#AAFF00"))
C1.addElement(ParagraphProperties(textalign="center"))
textdoc.styles.addElement(C1)

C2 = Style(name="C2style",family="table-cell", parentstylename='Standard', displayname="Color style 2")
C2.addElement(TableCellProperties(backgroundcolor="#FFFF00"))
C2.addElement(ParagraphProperties(textalign="center"))
textdoc.styles.addElement(C2)

C3 = Style(name="C3style",family="table-cell", parentstylename='Standard', displayname="Color style 3")
C3.addElement(TableCellProperties(backgroundcolor="#FFAA00"))
C3.addElement(ParagraphProperties(textalign="center"))
textdoc.styles.addElement(C3)

C4 = Style(name="C4style",family="table-cell", parentstylename='Standard', displayname="Color style 4")
C4.addElement(TableCellProperties(backgroundcolor="#FF0000"))
C4.addElement(ParagraphProperties(textalign="center"))
textdoc.styles.addElement(C4)

C5 = Style(name="C5style",family="table-cell", parentstylename='Standard', displayname="Color style 5")
C5.addElement(TableCellProperties(backgroundcolor="#FF0000"))
C5.addElement(ParagraphProperties(textalign="center"))
textdoc.styles.addElement(C5)

# Start the table, and describe the columns
table = Table(name="Overview")
table.addElement(TableColumn(numbercolumnsrepeated=1,stylename=nameColStyle))
for i in targetApps:
    table.addElement(TableColumn(numbercolumnsrepeated=len(testLabels)-1,stylename=valColStyle))
    table.addElement(TableColumn(numbercolumnsrepeated=1,stylename=viewColStyle))

#First row: application names
tr = TableRow()
table.addElement(tr)
tc = TableCell() #empty cell
tr.addElement(tc)
appcolumns=len(testLabels)
for a in targetApps: 
    print a
    tc = TableCell(numbercolumnsspanned=appcolumns, stylename="THstyle")
    tr.addElement(tc)
    p = P(stylename=tablecontents,text=unicode("Target application: %s "%a, PWENC))
    tc.addElement(p)
    for i in range(appcolumns-1): # create empty cells for the merged one
        tc = TableCell()
        tr.addElement(tc)
#Second row: test names
tr = TableRow()
table.addElement(tr)
tc = TableCell(stylename="THstyle") #empty cell
tr.addElement(tc)
p = P(stylename=tablecontents,text=unicode("Test case",PWENC))
tc.addElement(p)
for a in targetApps: 
    for tl in range(1, len(testLabelsShort)):   # we do not show the PPOI value
        tc = TableCell(stylename="THstyle")
        tr.addElement(tc)
        p = P(stylename=tablecontents,text=unicode(testLabelsShort[tl],PWENC))
        tc.addElement(p)
        tc.addElement(addAnn(testLabels[tl]))
    tc = TableCell(stylename="THstyle")
    tr.addElement(tc)
    p = P(stylename=tablecontents,text=unicode("Views",PWENC))
    tc.addElement(p)
    tc.addElement(addAnnL(testViewsExpl))

for testcase in values.keys():
    print testcase
    tr = TableRow()
    table.addElement(tr)
    tc = TableCell()
    tr.addElement(tc)
    p = P(stylename=tablecontents,text=unicode(testcase,PWENC))
    tc.addElement(p)
    for a in targetApps: 
        grades = valToGrade(values[testcase][a][1:])
        #grades = values[testcase][a][1:]
        #for val in values[testcase][a][1:]:   # we do not show the PPOI value
        #print grades
        for val in grades:   # we do not show the PPOI value
            tc = TableCell(valuetype="float", value=str(val), stylename='C'+str(int(val))+'style')
            tr.addElement(tc)
            p = P(text=str(val))
            tc.addElement(p)
	#ipdb.set_trace()#
        app, ttype = a.split()
        if ttype=="roundtrip":
            pdfpath=lpath+app+"/"+testcase+"-pair"
        else:
            pdfpath=lpath+app+"/"+testcase+"."+app+"-pair"
        tc = TableCell(stylename="THstyle")
        tr.addElement(tc)
        p = P(stylename=tablecontents,text=unicode("",PWENC))
	p.addText(" ")
	link = A(type="simple",href=pdfpath+"-z.pdf", text="F")
	p.addElement(link)
	p.addText("  ")
	link = A(type="simple",href=pdfpath+"-l.pdf", text="H")
	p.addElement(link)
	p.addText("  ")
	link = A(type="simple",href=pdfpath+"-p.pdf", text="T")
	p.addElement(link)
	p.addText("  ")
	link = A(type="simple",href=pdfpath+"-s.pdf", text="L")
	p.addElement(link)
        tc.addElement(p)


textdoc.spreadsheet.addElement(table)
textdoc.save(ofname)
    
