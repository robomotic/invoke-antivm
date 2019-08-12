#!/usr/bin/env python
# PasteBin API Class - Developed by acidvegas in Python (https://acid.vegas/pastebin)

'''
API Documentation:
	https://pastebin.com/api
'''

import urllib.parse
import urllib.request

# Values
format_values = {
	'4cs'           : '4CS',
	'6502acme'      : '6502 ACME Cross Assembler',
	'6502kickass'   : '6502 Kick Assembler',
	'6502tasm'      : '6502 TASM/64TASS',
	'abap'          : 'ABAP',
	'actionscript'  : 'ActionScript',
	'actionscript3' : 'ActionScript 3',
	'ada'           : 'Ada',
	'aimms'         : 'AIMMS',
	'algol68'       : 'ALGOL 68',
	'apache'        : 'Apache Log',
	'applescript'   : 'AppleScript',
	'apt_sources'   : 'APT Sources',
	'arm'           : 'ARM',
	'asm'           : 'ASM (NASM)',
	'asp'           : 'ASP',
	'asymptote'     : 'Asymptote',
	'autoconf'      : 'autoconf',
	'autohotkey'    : 'Autohotkey',
	'autoit'        : 'AutoIt',
	'avisynth'      : 'Avisynth',
	'awk'           : 'Awk',
	'bascomavr'     : 'BASCOM AVR',
	'bash'          : 'Bash',
	'basic4gl'      : 'Basic4GL',
	'dos'           : 'Batch',
	'bibtex'        : 'BibTeX',
	'blitzbasic'    : 'Blitz Basic',
	'b3d'           : 'Blitz3D',
	'bmx'           : 'BlitzMax',
	'bnf'           : 'BNF',
	'boo'           : 'BOO',
	'bf'            : 'BrainFuck',
	'c'             : 'C',
	'c_winapi'      : 'C (WinAPI)',
	'c_mac'         : 'C for Macs',
	'cil'           : 'C Intermediate Language',
	'csharp'        : 'C#',
	'cpp'           : 'C++',
	'cpp-winapi'    : 'C++ (WinAPI)',
	'cpp-qt'        : 'C++ (with Qt extensions)',
	'c_loadrunner'  : 'C: Loadrunner',
	'caddcl'        : 'CAD DCL',
	'cadlisp'       : 'CAD Lisp',
	'ceylon'        : 'Ceylon',
	'cfdg'          : 'CFDG',
	'chaiscript'    : 'ChaiScript',
	'chapel'        : 'Chapel',
	'clojure'       : 'Clojure',
	'klonec'        : 'Clone C',
	'klonecpp'      : 'Clone C++',
	'cmake'         : 'CMake',
	'cobol'         : 'COBOL',
	'coffeescript'  : 'CoffeeScript',
	'cfm'           : 'ColdFusion',
	'css'           : 'CSS',
	'cuesheet'      : 'Cuesheet',
	'd'             : 'D',
	'dart'          : 'Dart',
	'dcl'           : 'DCL',
	'dcpu16'        : 'DCPU-16',
	'dcs'           : 'DCS',
	'delphi'        : 'Delphi',
	'oxygene'       : 'Delphi Prism (Oxygene)',
	'diff'          : 'Diff',
	'div'           : 'DIV',
	'dot'           : 'DOT',
	'e'             : 'E',
	'ezt'           : 'Easytrieve',
	'ecmascript'    : 'ECMAScript',
	'eiffel'        : 'Eiffel',
	'email'         : 'Email',
	'epc'           : 'EPC',
	'erlang'        : 'Erlang',
	'euphoria'      : 'Euphoria',
	'fsharp'        : 'F#',
	'falcon'        : 'Falcon',
	'filemaker'     : 'Filemaker',
	'fo'            : 'FO Language',
	'f1'            : 'Formula One',
	'fortran'       : 'Fortran',
	'freebasic'     : 'FreeBasic',
	'freeswitch'    : 'FreeSWITCH',
	'gambas'        : 'GAMBAS',
	'gml'           : 'Game Maker',
	'gdb'           : 'GDB',
	'genero'        : 'Genero',
	'genie'         : 'Genie',
	'gettext'       : 'GetText',
	'go'            : 'Go',
	'groovy'        : 'Groovy',
	'gwbasic'       : 'GwBasic',
	'haskell'       : 'Haskell',
	'haxe'          : 'Haxe',
	'hicest'        : 'HicEst',
	'hq9plus'       : 'HQ9 Plus',
	'html4strict'   : 'HTML',
	'html5'         : 'HTML 5',
	'icon'          : 'Icon',
	'idl'           : 'IDL',
	'ini'           : 'INI file',
	'inno'          : 'Inno Script',
	'intercal'      : 'INTERCAL',
	'io'            : 'IO',
	'ispfpanel'     : 'ISPF Panel Definition',
	'j'             : 'J',
	'java'          : 'Java',
	'java5'         : 'Java 5',
	'javascript'    : 'JavaScript',
	'jcl'           : 'JCL',
	'jquery'        : 'jQuery',
	'json'          : 'JSON',
	'julia'         : 'Julia',
	'kixtart'       : 'KiXtart',
	'kotlin'        : 'Kotlin',
	'latex'         : 'Latex',
	'ldif'          : 'LDIF',
	'lb'            : 'Liberty BASIC',
	'lsl2'          : 'Linden Scripting',
	'lisp'          : 'Lisp',
	'llvm'          : 'LLVM',
	'locobasic'     : 'Loco Basic',
	'logtalk'       : 'Logtalk',
	'lolcode'       : 'LOL Code',
	'lotusformulas' : 'Lotus Formulas',
	'lotusscript'   : 'Lotus Script',
	'lscript'       : 'LScript',
	'lua'           : 'Lua',
	'm68k'          : 'M68000 Assembler',
	'magiksf'       : 'MagikSF',
	'make'          : 'Make',
	'mapbasic'      : 'MapBasic',
	'markdown'      : 'Markdown',
	'matlab'        : 'MatLab',
	'mirc'          : 'mIRC',
	'mmix'          : 'MIX Assembler',
	'modula2'       : 'Modula 2',
	'modula3'       : 'Modula 3',
	'68000devpac'   : 'Motorola 68000 HiSoft Dev',
	'mpasm'         : 'MPASM',
	'mxml'          : 'MXML',
	'mysql'         : 'MySQL',
	'nagios'        : 'Nagios',
	'netrexx'       : 'NetRexx',
	'newlisp'       : 'newLISP',
	'nginx'         : 'Nginx',
	'nimrod'        : 'Nimrod',
	'text'          : 'None',
	'nsis'          : 'NullSoft Installer',
	'oberon2'       : 'Oberon 2',
	'objeck'        : 'Objeck Programming Langua',
	'objc'          : 'Objective C',
	'ocaml-brief'   : 'OCalm Brief',
	'ocaml'         : 'OCaml',
	'octave'        : 'Octave',
	'oorexx'        : 'Open Object Rexx',
	'pf'            : 'OpenBSD PACKET FILTER',
	'glsl'          : 'OpenGL Shading',
	'oobas'         : 'Openoffice BASIC',
	'oracle11'      : 'Oracle 11',
	'oracle8'       : 'Oracle 8',
	'oz'            : 'Oz',
	'parasail'      : 'ParaSail',
	'parigp'        : 'PARI/GP',
	'pascal'        : 'Pascal',
	'pawn'          : 'Pawn',
	'pcre'          : 'PCRE',
	'per'           : 'Per',
	'perl'          : 'Perl',
	'perl6'         : 'Perl 6',
	'php'           : 'PHP',
	'php-brief'     : 'PHP Brief',
	'pic16'         : 'Pic 16',
	'pike'          : 'Pike',
	'pixelbender'   : 'Pixel Bender',
	'pli'           : 'PL/I',
	'plsql'         : 'PL/SQL',
	'postgresql'    : 'PostgreSQL',
	'postscript'    : 'PostScript',
	'povray'        : 'POV-Ray',
	'powershell'    : 'Power Shell',
	'powerbuilder'  : 'PowerBuilder',
	'proftpd'       : 'ProFTPd',
	'progress'      : 'Progress',
	'prolog'        : 'Prolog',
	'properties'    : 'Properties',
	'providex'      : 'ProvideX',
	'puppet'        : 'Puppet',
	'purebasic'     : 'PureBasic',
	'pycon'         : 'PyCon',
	'python'        : 'Python',
	'pys60'         : 'Python for S60',
	'q'             : 'q/kdb+',
	'qbasic'        : 'QBasic',
	'qml'           : 'QML',
	'rsplus'        : 'R',
	'racket'        : 'Racket',
	'rails'         : 'Rails',
	'rbs'           : 'RBScript',
	'rebol'         : 'REBOL',
	'reg'           : 'REG',
	'rexx'          : 'Rexx',
	'robots'        : 'Robots',
	'rpmspec'       : 'RPM Spec',
	'ruby'          : 'Ruby',
	'gnuplot'       : 'Ruby Gnuplot',
	'rust'          : 'Rust',
	'sas'           : 'SAS',
	'scala'         : 'Scala',
	'scheme'        : 'Scheme',
	'scilab'        : 'Scilab',
	'scl'           : 'SCL',
	'sdlbasic'      : 'SdlBasic',
	'smalltalk'     : 'Smalltalk',
	'smarty'        : 'Smarty',
	'spark'         : 'SPARK',
	'sparql'        : 'SPARQL',
	'sqf'           : 'SQF',
	'sql'           : 'SQL',
	'standardml'    : 'StandardML',
	'stonescript'   : 'StoneScript',
	'sclang'        : 'SuperCollider',
	'swift'         : 'Swift',
	'systemverilog' : 'SystemVerilog',
	'tsql'          : 'T-SQL',
	'tcl'           : 'TCL',
	'teraterm'      : 'Tera Term',
	'thinbasic'     : 'thinBasic',
	'typoscript'    : 'TypoScript',
	'unicon'        : 'Unicon',
	'uscript'       : 'UnrealScript',
	'upc'           : 'UPC',
	'urbi'          : 'Urbi',
	'vala'          : 'Vala',
	'vbnet'         : 'VB.NET',
	'vbscript'      : 'VBScript',
	'vedit'         : 'Vedit',
	'verilog'       : 'VeriLog',
	'vhdl'          : 'VHDL',
	'vim'           : 'VIM',
	'visualprolog'  : 'Visual Pro Log',
	'vb'            : 'VisualBasic',
	'visualfoxpro'  : 'VisualFoxPro',
	'whitespace'    : 'WhiteSpace',
	'whois'         : 'WHOIS',
	'winbatch'      : 'Winbatch',
	'xbasic'        : 'XBasic',
	'xml'           : 'XML',
	'xorg_conf'     : 'Xorg Config',
	'xpp'           : 'XPP',
	'yaml'          : 'YAML',
	'z80'           : 'Z80 Assembler',
	'zxbasic'       : 'ZXBasic'
}

expire_values = {
	'N'   : 'Never',
	'10M' : '10 Minutes',
	'1H'  : '1 Hour',
	'1D'  : '1 Day',
	'1W'  : '1 Week',
	'2W'  : '2 Weeks',
	'1M'  : '1 Month'
}

private_values = {
	'0' : 'Public',
    '1' : 'Unlisted',
    '2' : 'Private'
}

class PasteBin:
	def __init__(self, api_dev_key, api_user_key=None, timeout=10):
		self.api_dev_key  = api_dev_key
		self.api_user_key = api_user_key
		self.timeout      = timeout

	def api_call(self, method, params):
		response = urllib.request.urlopen('https://pastebin.com/api/' + method, urllib.parse.urlencode(params).encode('utf-8'), timeout=self.timeout)
		return response.read().decode()

	def create_user_key(self, username, password):
		params = {'api_dev_key':self.api_dev_key, 'api_user_name':username, 'api_user_password':password}
		return self.api_call('api_login.php', params)

	def paste(self, data, guest=False, name=None, format=None, private=None, expire=None):
		params = {'api_dev_key':self.api_dev_key, 'api_option':'paste', 'api_paste_code':data}
		if not guest : params['api_user_key']          = self.api_user_key
		if name      : params['api_paste_name']        = name
		if format    : params['api_paste_format']      = format
		if private   : params['api_paste_private']     = private
		if expire    : params['api_paste_expire_date'] = expire
		return self.api_call('api_post.php', params)

	def list_pastes(self, results_limit=None):
		params = {'api_dev_key':self.api_dev_key, 'api_user_key':self.api_user_key, 'api_option':'list'}
		if results_limit: # Default 50, Minimum 1, Maximum 1000
			params['api_results_limit'] = results_limit
		return self.api_call('api_post.php', params)

	def trending_pastes(self):
		params = {'api_dev_key':self.api_dev_key, 'api_option':'trends'}
		return self.api_call('api_post.php', params)

	def delete_paste(self, paste_key):
		params = {'api_dev_key':self.api_dev_key, 'api_user_key':self.api_user_key, 'api_paste_key':paste_key, 'api_option':'delete'}
		return self.api_call('api_post.php', params)

	def user_info(self):
		params = {'api_dev_key':self.api_dev_key, 'api_user_key':self.api_user_key, 'api_option':'userdetails'}
		return self.api_call('api_post.php', params)

	def raw_pastes(self, paste_key):
		params = {'api_dev_key':self.api_dev_key, 'api_user_key':self.api_user_key, 'api_paste_key':paste_key, 'api_option':'show_paste'}
		return self.api_call('api_raw.php', params)