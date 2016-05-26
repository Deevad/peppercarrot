#!/usr/bin/env python3

# Script to merge translator credits of Pepper&Carrot
#
# Dependencies (can be installed with pip3):
# * unidecode
#
# License: GPL version 3 or later
#          See the file LICENSE that came with this script or
#          http://www.gnu.org/copyleft/gpl.html
#

import sys
import re
import itertools
from unidecode import unidecode
from collections import defaultdict


def same_ascii_letters_case_insensitive(str1, str2):
	'''
	Check whether the smart ASCII representations of str1 and str2 match,
	ignoring case and everything but letters
	'''

	return all(
		a == b
		for a, b
		in itertools.zip_longest(
			filter(str.isalpha, unidecode(str1.lower())),
			filter(str.isalpha, unidecode(str2.lower()))
		)
	)


def find_matching(comparison_function, needle, haystack):
	'''
	Find an element in the iterable haystack that is the same as needle
	according to comparison_function
	'''

	for element in haystack:
		if comparison_function(needle, element):
			return element
	return None


def merge_translators(iterable,
                      merge_line_format = re.compile(r'^\* ([^:]+) *: (.*) *\n'),
                      and_re = re.compile(r' and | & | og |, corrections: |, title-art: |, | / '),
                      comparison_function = same_ascii_letters_case_insensitive):
	'''
	Merge translators defined in iterable in the format specified by
	merge_line_format
	
	The default for merge_line_format is a regex matching (a whole lot more
	than) e.g.:
	* Language: Translator 1, Translator 2 and Translator 3
	
	Translator names are considered "the same" when comparison_function returns
	true for them. All used names are remembered for the duration of the
	function call. When a name is the same (according to comparison_function) as
	a used one but they don't fully equal, the first encountered name is picked
	and a warning is written to standard output.
	'''

	languages = defaultdict(list)
	all_known_translators = []

	for line in iterable:
		match = merge_line_format.match(line)
		if match is not None:
			lang = match.group(1)
			translators_string = match.group(2)
			translators = and_re.split(translators_string)

			for translator in translators:
				known_translator = find_matching(comparison_function, translator, all_known_translators)

				if known_translator is not None:
					if translator != known_translator:
						print('Found other orthography for {}: {}, using first one'.format(known_translator, translator), file=sys.stderr)
						translator = known_translator
				else:
					all_known_translators.append(translator)

				known_translator = find_matching(comparison_function, translator, languages[lang])
				if known_translator is None:
					languages[lang].append(translator)
	
	return languages


def nice_listlike_to_string(listlike, inter=', ', lastinter=' and '):
	'''
	Returns a nice string representation of listlike
	
	listlike has to support the len() function, that's why it's called listlike.
	'''

	length = len(listlike)
	if length == 0:
		return ''
	elif length == 1:
		return listlike[0]
	else:
		return '{allbutlast}{and_txt}{last}'.format(
			allbutlast = inter.join(listlike[:-1]),
			and_txt = lastinter,
			last = listlike[-1]
		)


def print_translators(languages,
                      output_format = '* {language}: {translators}\n',
                      sort_by_language = True):
	'''
	Print translation credits
	
	languages has to be a dict from language name to an iterable of translators.
	'''

	items = languages.items()

	if sort_by_language:
		items = sorted(items)

	for lang, translators in items:
		print(output_format.format(language=lang, translators=nice_listlike_to_string(translators)))


def main():
	'''
	Merge translator credits, reading from a file or stdin

	If a command line argument is given, use it as a file name. If not, read
	from standard input.
	'''

	if len(sys.argv) >= 2:
		filehandle = open(sys.argv[1])
	else:
		filehandle = sys.stdin

	print_translators(merge_translators(filehandle))

	if filehandle is not sys.stdin:
		filehandle.close()

if __name__ == '__main__':
	main()
