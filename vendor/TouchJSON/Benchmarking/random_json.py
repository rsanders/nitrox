#!/usr/bin/python

import simplejson

import random

theLetters = 'ABCDEF'

def randomInt(depth = 0):
	return int(random.uniform(-1000000, 1000000))
def randomFloat(depth = 0):
	return random.random()

def randomString(depth = 0, inCount = 100):
	return ''.join([random.choice(theLetters) for x in xrange(1, int(random.uniform(1, inCount)))])

def randomList(depth = 0):
	return [randomSomething(depth - 1) for x in xrange(0, int(random.uniform(1, 100)))]

def randomDict(depth = 0):
	return dict([(randomString(10), randomSomething(depth - 1)) for x in xrange(0, int(random.uniform(1, 100)))])

def randomSomething(depth = 0):
	theFunctions = [randomInt, randomFloat, randomString]
	if depth > 0:
		theFunctions += [randomList, randomDict]
	theFunction = random.choice(theFunctions)
	return theFunction(depth - 1)
	
d = randomDict(6)

s = simplejson.dumps(d)
print len(s) / 1024

file('/Users/schwa/Desktop/d.json', 'w').write(s)