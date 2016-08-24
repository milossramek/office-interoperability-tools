from setuptools import setup, find_packages

from setuptools import setup
setup(
	# basic stuff here
	name = "OfficeITools",
	version = "0.7",
	description = "Tools for evaluation of interoperability of office packages",
	author = "Milos Sramek",
	author_email = "milos.sramek@soit.sk",
	#url = 
	license = "GPLv3",
	#data_files = data_files,
	packages = find_packages(),
	scripts = ['docompare.py','doeval.py', 'dolib.py', 'dogenall.sh','doviews.sh', 'gdconvert.py', 'msoconvert.sh', 'dogood.sh'],
	install_requires=[
		'tifffile>=0.4',
		'Pillow>=2.6.1',
		'numpy>=1.6.1',
		'scipy>=0.17',
		#'distribute>=0.6.28',
		'odfpy>=0.9.6',
		#'ipdb>=0.7'
	]
	#cmdclass = {"uninstall" : uninstall,
		#"install" : install,
		#"install_data" : install_data},
	#ext_modules = extensions,
	)
