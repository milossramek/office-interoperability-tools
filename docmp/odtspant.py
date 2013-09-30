from lxml import etree
from StringIO import StringIO
from copy import deepcopy
import ipdb
#ipdb.set_trace()

def isP(item):
	if item.tag[-2:]=='}p':
		return True
	else:
		return False

def hasText(item):
	if 	item.text == None: 
		return False
	else:
		return True


def isNotTSpan(item):
	if item.tag.find('span') >= 0:
		for key in item.keys():
			if key.find('style-name') >=0 :
				if item.attrib[key].find('T') != 0 : return True
	return False

def isT7Span(item):
	if item.tag.find('span') >= 0:
		for key in item.keys():
			if key.find('style-name') >=0 :
				if item.attrib[key].find('T7') ==0 : return True
	return False

def isTSpan(item):
	if item.tag.find('span') >= 0:
		for key in item.keys():
			if key.find('style-name') >=0 :
				if item.attrib[key].find('T') ==0 : return True
	return False

def isOMPSpan(item):
	if item.tag.find('span') >= 0:
		for key in item.keys():
			if key.find('style-name') >=0 :
				if item.attrib[key].find('OOoMenuPath') == 0 : return True
	return False

def isODSpan(item):
	if item.tag.find('span') >= 0:
		for key in item.keys():
			if key.find('style-name') >=0 :
				if item.attrib[key].find('OOoDefault') == 0 : return True
	return False

def isOESpan(item):
	if item.tag.find('span') >= 0:
		for key in item.keys():
			if key.find('style-name') >=0 :
				if item.attrib[key].find('OOoEmphasis') == 0 : return True
	return False

def listT(tree):
	for item in tree.iter():
		if item.tag.find('span') >= 0:
			for key in item.keys():
				if key.find('style-name') >=0 :
					if item.attrib[key].find('T') ==0 :
						print item.tag, item.attrib[key]

def mergeOMPSpans(tree):
	"""
	Merge consecutive spans with text:style-name="OOoMenuPath"
	"""
	for item in tree.iter():
		#if item.tag.find('}p') >= 0:
		if isP(item):
			#print item, ' - ', item.text
			firstOMPChild=None
			for child in item.getchildren():
				if isOMPSpan(child): 
					if len(child.getchildren()) > 0:
						firstOMPChild = None
					else:
						if hasText(child): 
							if len(child.getchildren()) > 0:
								print 'LLLLLLLLLLLLLLLLLLL:',child.text, 'XX',child.getchildren()[0].text
							if(firstOMPChild == None):
								firstOMPChild = child
							else:
								firstOMPChild.text = firstOMPChild.text+child.text
								item.remove(child)
						else:
							firstOMPChild = None
							#ipdb.set_trace()
				else:
					firstOMPChild = None

def mergeOESpans(tree):
	"""
	Merge consecutive spans with text:style-name="OOoEmphasis"
	"""
	for item in tree.iter():
		#if item.tag.find('}p') >= 0:
		if isP(item):
			#print item, ' - ', item.text
			firstOEChild=None
			for child in item.getchildren():
				if isOESpan(child): 
					if len(child.getchildren()) > 0:
						firstOEChild = None
					else:
						if hasText(child): 
							if len(child.getchildren()) > 0:
								print 'LLLLLLLLLLLLLLLLLLL:',child.text, 'XX',child.getchildren()[0].text
							if(firstOEChild == None):
								firstOEChild = child
							else:
								firstOEChild.text = firstOEChild.text+child.text
								item.remove(child)
						else:
							firstOEChild = None
							#ipdb.set_trace()
				else:
					firstOEChild = None

def mergeODSpans(tree):
	"""
	Merge consecutive spans with text:style-name="OOoDefault"
	"""
	for item in tree.iter():
		#if item.tag.find('}p') >= 0:
		if isP(item):
			#print item, ' - ', item.text
			firstODChild=None
			for child in item.getchildren():
				if isODSpan(child): 
					if len(child.getchildren()) > 0:
						firstODChild = None
					else:
						if hasText(child): 
							if len(child.getchildren()) > 0:
								print 'LLLLLLLLLLLLLLLLLLL:',child.text, 'XX',child.getchildren()[0].text
							if(firstODChild == None):
								firstODChild = child
							else:
								firstODChild.text = firstODChild.text+child.text
								item.remove(child)
						else:
							firstODChild = None
							#ipdb.set_trace()
				else:
					firstODChild = None

def mergeTSpans(tree):
	"""
	Merge consecutive spans with text:style-name="Txx"
	and
	Drawback: may corrupt direct formatting (which is done by Txx spans
	"""
	for iitem in tree.xpath('//*'):
		if isP(iitem):
			item = deepcopy(iitem)
			changed = True
			while changed:
				#pitem(item)
				changed = False
				#ipdb.set_trace()
				elist = list(item)
				for el in range(len(elist)):
					#print 'P: ', el
					if isTSpan(elist[el]) and len(elist[el].getchildren()) == 0:
						etext=''
						etail=''
						if elist[el].text: etext = elist[el].text
						if elist[el].tail: etail = elist[el].tail
						if el == 0:
							if item.text:
								item.text = item.text + etext + etail
							else:
								item.text = etext + etail
						else:
							eetail=''
							if elist[el-1].tail: 
								eetail = elist[el-1].tail
							elist[el-1].tail = eetail + etext + etail
						item.remove(elist[el])
						changed = True
						break
			#pitem(item)
			#ipdb.set_trace()
			iitem.getparent().replace(iitem, item)

def cleanTSpans(tree):
	"""
	Merge consecutive spans with text:style-name="Txx"
	and
	Drawback: may corrupt direct formatting (which is done by Txx spans
	"""
	for iitem in tree.xpath('//*'):
		if isP(iitem):
			item = deepcopy(iitem)
			elist = list(item)
			for el in range(len(elist)):
				if len(elist[el].getchildren()) > 0:
					child = elist[el].getchildren()[0]
					if isTSpan(child):
						etext=''
						if elist[el].text: etext = elist[el].text
						ctext=''
						if child.text: ctext = child.text
						elist[el].text = etext+ctext
						elist[el].remove(child)
			pitem(item)
			#ipdb.set_trace()
			iitem.getparent().replace(iitem, item)

def reorgPar(tree):
	"""
	Merge consecutive spans with text:style-name="Txx"
	and
	remove a text:style-name="Txx" span if it is the only child of a different span style
	Drawback: may corrupt direct formatting (which is done by Txx spans
	"""
	pcount = 0
	for item in tree.iter():
		#if item.tag.find('}p') >= 0:
		if isP(item):
			pcount +=1
			if item.text == None: txlist = ['']
			else: txlist = []
			for tx in item.itertext(): txlist.append(tx)
			for tx in item.itertext(): tx = "XXX"
			desclist=[]
			for dd in item.iterdescendants(): desclist.append(dd)
			#print len(txlist), len(desclist)

			if len(txlist) == len(desclist):
				print len(txlist), txlist[0]
			ipdb.set_trace()
			if pcount > 4: break

def listTxElem(tree):
	for node in tree.xpath('//*|//text()'):
    		if isinstance(node, basestring):
        		if node.strip():
            			print repr(node.strip())
    		else:
        		print '<%s>' % node.tag

def pitem(item):
	print '{',item.text,'}'
	for it in list(item):
		print it.tag, '{',it.text,'|', it.tail,'}'
	print

tree = etree.parse('content.xml')
root = tree.getroot()
mergeTSpans(tree)
cleanTSpans(tree)
#mergeOMPSpans(tree)
#mergeODSpans(tree)
#mergeOESpans(tree)

tree.write ( 'c.xml' )
