#
# dolib.py v1.0 - 2013-09-30
#
# some useful functions 
#
# Copyright (C) 2013 Milos Sramek <milos.sramek@soit.sk>
# Licensed under the GNU LGPL v3 - http://www.gnu.org/licenses/gpl.html
# - or any later version.
#

import SimpleITK as sitk
import numpy as np
import sys, os, tempfile
import ipdb
#ipdb.set_trace()

def toitk(image):
	"""
	Convert to ITK, if necessary, and return True as the first return value if input is itk image
	"""
	if isinstance(image, sitk.Image):
		return True, image
	else:
		if image.dtype=='bool':
			return False, sitk.GetImageFromArray(image.astype(np.int8))
		else:
			return False, sitk.GetImageFromArray(image)

def fromitk(itkImage, wasitk):
	"""
	Convert to numpy array, if wasitk==False
	"""
	if wasitk:
		return itkImage
	else:
		return sitk.GetArrayFromImage(itkImage)

def distanceitk(image, signed=False):
	wasitk, itkImage = toitk(image)
	if signed:
		itkImage = sitk.DanielssonDistanceMap(itkImage)
	else:
		itkImage = sitk.SignedDanielssonDistanceMap(itkImage)
	return fromitk(itkImage, wasitk)


def pdf2array(pdffile, res):
	"""
	read pdf file and convert it to numpy array
	Only the first page is converted
	"""
	tname = tmpname()+'.tif'
	cmd = 'cat %s | gs -dQUIET -dNOPAUSE -sDEVICE=tiffgray -r%d -sOutputFile=%s -'%(pdffile, res, tname)
	os.system(cmd)
	img = (sitk.GetArrayFromImage(sitk.ReadImage(tname))).astype(np.uint8)
	if img.ndim == 3:	# currently we work only with the first page
		return img[0]
	else:
		return img

	
def getBBox(img1, img2=None):
	"""
	get a bounding box of nonzero pixels of one or two images
	"""
	if img2 == None:
		B = np.argwhere(img1)
		if B.shape[0] ==0:
			raise MyException("Error in getBBox: Empy document ")
		return B.min(0), B.max(0) + 1
	else:
		min1, max1 = getBBox(img1)
		min2, max2 = getBBox(img2)
		return np.minimum(min1, min2), np.maximum(max1, max2)

def toBin(img):
	return (img < 200).astype(np.uint8)

def tmpname():
	f = tempfile.NamedTemporaryFile(delete=True)
	f.close()
	return f.name

def GetLine(img, seglist, seg):
	"""
	get the 'seg' line of the 'seglist' list of lines fron the image
	"""
	return img[seglist[seg][0]:seglist[seg][0]+seglist[seg][1]]


def GetLineSegments(itrim):
	"""
	Segment an image in lines and interline spaces
	Returns lists of both (position width)
	"""
	asum = np.sum(itrim, axis=1)
	abin = asum > 0
	sp = []
	tx = []
	lastval=-1
	lastpos=-1
	for i in range(0, abin.size):
		if abin[i] != lastval:
			lastval = abin[i]
			if lastval:
				tx.append(np.array((i,0)))
				if i>1: 
					sp[-1][1] = i-sp[-1][0]
			else:
				sp.append(np.array((i,0)))
				if i>1: 
					tx[-1][1] = i-tx[-1][0]
	# set the last segment lenght
	#ipdb.set_trace()
	if tx[-1][1] == 0: tx[-1][1] = itrim.shape[0] - tx[-1][0]
	if sp[-1][1] == 0: sp[-1][1] = itrim.shape[0] - sp[-1][0]
	return tx, sp

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

def alignLineIndex(l1, l2):
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
		ovlaps[i] = 1.0 - float(np.sum(diff)) / (np.sum(ll2) + np.sum(ll1))

	bf = ovlaps.argmax(); # best fit position
	ll1 = np.zeros(l2.shape,dtype=np.uint8)
	ll1[bf:bf+l1.shape[0]] = l1
	ll2=l2
	if len(sr1) > len(sr2):
		overlayedLines = ovlLine(ll2, ll1)
	else:
		overlayedLines = ovlLine(ll1, ll2)
	ll1 = distanceitk(ll1)
	ll2 = distanceitk(ll2)
	#ipdb.set_trace()
	return overlayedLines, (abs(horizPosErr), ovlaps[bf], np.average(abs(ll1-ll2)), np.max(abs(ll1-ll2)))

def a4width(): return 210.0
def a4height(): return 297.0
def i2mm(): return 25.4	# inch to mm conversion
def px2mm(val, dpi):
	"""
	convert 'val' im mm to pixels
	"""
	return val*i2mm()/dpi

