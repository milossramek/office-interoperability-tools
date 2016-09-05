#!  /usr/bin/python

# remove direct formating from the content.xml file of an odt document
# removes the Txxx and OOoDefault styles (if they exist)
# may corrupt direct formatting
# not all Txxx styles are removed

# Usage:
#  mkdir xxx
#  cd xxx
#  unzip ../doc.odt
#  odtspant.py # the file c.xml is created
#  mv c.xml content.xml
#  zip -r ../doc-new.odt
#  

# Author Milos Sramek milos.sramek@soit.sk
# Use as you wish, without warranty

from lxml import etree
import sys, getopt
import ipdb
import zipfile
import pickle
#ipdb.set_trace()

def usage():
    global rankfile, genranks 
    print "%s: Create tag rank statistics or evaluate rank statistics for docx files."%sys.argv[0]
    print "\tUsage: %s switches files"%(sys.argv[0])
    print "\tEvaluation data will be written to standard output"
    print 
    print "\tSwitches:"
    print "\t\t -c ............ Create a pickle file with rank statistics {evaluate rank statistics}"
    print "\t\t -r filename ... Pickle file name with rank statisctics {%s}"%rankfile
    print "\t\t -h ............ this usage"

def parsecmd():
    global rankfile, genranks
    try:
        opts, Names = getopt.getopt(sys.argv[1:], "hcr:", [])
    except getopt.GetoptError as err:
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        usage()
        sys.exit(2)
    for o, a in opts:
        if o in ("-c"):
            genranks=True
        elif o in ("-r"):
            rankfile = a
        elif o in ("-h"):
            usage()
            sys.exit(0)
        else:
            assert False, "unhandled option"
    return Names

def getName(item):
    return item.split("}")[-1]

def isTag(item,tag):
    return item.tag.find(tag) >= 0

ignoreTags = ["document", "body", "proofErr", "bookmarkStart", "bookmarkEnd", "lang", "rFonts"]
ignoreAttr = ["rsidRDefault", "rsidRPr", "rsidR", "rsidP", "rsidSect", "rsidTr", "rsidDel", "rsid", "name", "descr", "uri", "anchorId", "editId", "embed", "id"]
ignoreAttrVal = ['gfxdata', 'coordsize', 'path', 'xrange', 'connectlocs', 'textboxrect', 'connectangles', 'strokeweight', '']
propertysTagList = ["w:rPr", "w:pPr", "w:tblPr", "w:tcPr", "w:tcBorders", "w:tcBorders", "w:sectPr"]

def inIgnoreList(istr, ilist):
    for il in ilist:
        if istr==il: return True
    return False

def getTagString(item):
    '''get tag string '''
    tag = getName(item.tag)
    if inIgnoreList(tag, ignoreTags):
        return ''
    else :
        if item.prefix is None:
            return tag 
        else:
            return item.prefix+":"+tag 

def getChildrenString(item):
    chstr=""
    for child in item.getchildren():
        chstr += ptag(child)
    return chstr

def getAttrString(item):
    '''format attributes with name and value'''
    attribs=[]
    for a in item.attrib.keys():
        aname = getName(a)
        if not inIgnoreList(aname, ignoreAttr):
            attribs.append(getName(a))
            #if inIgnoreList(aname, ignoreAttrVal):
                #attribs.append(getName(a))
            #else:
                #try:
                    #val = int(item.attrib[a])
                    #attribs.append(getName(a))
                #except:
                    #attribs.append(getName(a)+ "_" + item.attrib[a])
    attribs.sort()
    astr=""
    for s in attribs: astr += "+"+s
    return astr

def ptag(item):
    tagString = getTagString(item)
    if tagString == '': return ''

    return tagString + getAttrString(item)

def merge_two_dicts(x, y):
    '''Given two dicts, merge them into a new dict as a shallow copy.'''
    z = x.copy()
    z.update(y)
    return z

def getTagsFromFile(text):
    ''' get statistics on general tags and properties tags'''
    tree = etree.fromstring(text) 
    #root = tree.getroot()
    gentags ={}
    proptags ={}
    for item in tree.xpath('//*'):
        proptag=''
        if getTagString(item) in propertysTagList: 
            for child in item.getchildren():
                childstr=getTagString(child)
                if childstr != '':
                    proptag = ptag(item)+"-"+childstr+getAttrString(child)
        if proptag != '': 
            if proptags.has_key(proptag):
                proptags[proptag] += 1
            else:
                proptags[proptag] = 1
        gentag=ptag(item)
        if gentag != '': 
            if gentags.has_key(gentag):
                gentags[gentag] += 1
            else:
                gentags[gentag] = 1
    return gentags, proptags


namelist=["word/document.xml", "word/styles.xml"]
namelist=["word/document.xml"]

def getTags(names, verbose):
    alltags = {}
    for iname in names:
        if verbose: print "Procesing %s"%iname
        try:
            file = zipfile.ZipFile(iname, "r")

            for name in namelist:
                data = file.read(name)
                gt, pt = getTagsFromFile(data)
                gptags=merge_two_dicts(gt, pt)  #merge general and property tags
                if iname in alltags:
                    alltags[iname] = merge_two_dicts(alltags[iname], gptags)
                else:
                    alltags[iname] = gptags
        except:
            pass
    return alltags

def getTagFrequency(names, rankfile):
    alltags = getTags(names, True)

    #summaries
    tagcount={}    #count all occurences
    tagfreq={}     #count only files
    for filename in alltags.keys():
        for k in alltags[filename].keys():
            if k in tagfreq:
                tagcount[k] += alltags[filename][k]
                tagfreq[k] += 1
            else :
                tagcount[k] = alltags[filename][k]
                tagfreq[k] = 1

    fcount = len(names)
    for xmltag in tagfreq.keys():
        tagfreq[xmltag] = float(tagfreq[xmltag]) / fcount

    return tagfreq


def getRanks(names, tagfreq):
    alltags = getTags(names, False)

    for name in alltags.keys():
        tagstrings = {}
        for k in alltags[name].keys():
            try:
                tagstrings[k] = tagfreq[k]
            except:
                tagstrings[k] = 0
        L = sorted(tagstrings.items(), key=lambda (k, v): v)
        print name, L[0][1], 
        for ll in L: print ll[0],
        print 

rankfile="gtagfreq.pickle"
genranks=False
names = parsecmd()
if genranks:
    tagfreq = getTagFrequency(names, rankfile)
    with open(rankfile, 'wb') as handle:
        pickle.dump(tagfreq, handle)
else:
    with open(rankfile, 'rb') as handle:
        tagfreq = pickle.load(handle)
    getRanks(names, tagfreq)
