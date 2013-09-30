from setuptools import setup, find_packages

from setuptools import setup
setup(
	# basic stuff here
	name = "DoCmp",
	version = "0.6",
	description = "Tools for processing plant growth image data at GMI",
	author = "Milos Sramek",
	author_email = "milos.sramek@soit.sk",
	#url = 
	license = "GPLv3",
	#data_files = data_files,
	packages = find_packages(),
	scripts = ['docompare.py','doeval.py', 'dolib.py', 'odtspant.py', 'dogenall.sh','doviews.sh', 'gdconvert.py'],
	#install_requires=[
		#'SimpleITK>=0.6.1',
		#'numpy>=1.6.1',
		#'distribute>=0.6.28',
		#'odfpy>=0.9.6',
		#'ipdb>=0.7'
	#]
	#cmdclass = {"uninstall" : uninstall,
		#"install" : install,
		#"install_data" : install_data},
	#ext_modules = extensions,
	)
