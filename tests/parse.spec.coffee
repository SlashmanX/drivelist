m = require('mochainon')
parse = require('../lib/parse')

describe 'Parse:', ->

	it 'should return an empty object if no input', ->
		m.chai.expect(parse()).to.deep.equal({})

	it 'should return an empty object if input is an empty string', ->
		m.chai.expect(parse('')).to.deep.equal({})

	it 'should return an empty object if input is a string containing only spaces', ->
		m.chai.expect(parse('    ')).to.deep.equal({})

	it 'should parse a single device', ->
		m.chai.expect parse '''
			device: /dev/disk1
			description: Macintosh HD
			size: 249.8 GB
			mountpoint: /
		'''
		.to.deep.equal [
			device: '/dev/disk1'
			description: 'Macintosh HD'
			size: '249.8 GB'
			mountpoint: '/'
		]

	it 'should parse multiple devices', ->
		m.chai.expect parse '''
			device: /dev/disk1
			description: Macintosh HD
			size: 249.8 GB
			mountpoint: /

			device: /dev/disk2
			description: elementary OS
			size: 15.7 GB
			mountpoint: /Volumes/Elementary
		'''
		.to.deep.equal [
			device: '/dev/disk1'
			description: 'Macintosh HD'
			size: '249.8 GB'
			mountpoint: '/'
		,
			device: '/dev/disk2'
			description: 'elementary OS'
			size: '15.7 GB'
			mountpoint: '/Volumes/Elementary'
		]

	it 'should ignore new lines after the output', ->
		m.chai.expect parse '''
			device: /dev/disk1
			description: Macintosh HD
			size: 249.8 GB
			mountpoint: /

			device: /dev/disk2
			description: elementary OS
			size: 15.7 GB
			mountpoint: /Volumes/Elementary



		'''
		.to.deep.equal [
			device: '/dev/disk1'
			description: 'Macintosh HD'
			size: '249.8 GB'
			mountpoint: '/'
		,
			device: '/dev/disk2'
			description: 'elementary OS'
			size: '15.7 GB'
			mountpoint: '/Volumes/Elementary'
		]

	it 'should parse multiple devices that are heterogeneous', ->
		m.chai.expect parse '''
			hello: world
			foo: bar

			hey: there
		'''
		.to.deep.equal [
			hello: 'world'
			foo: 'bar'
		,
			hey: 'there'
		]

	it 'should set null for values without keys', ->
		m.chai.expect parse '''
			hello:
		'''
		.to.deep.equal [
			hello: null
		]

	it 'should interpret a word without colon as a key without value', ->
		m.chai.expect parse '''
			hello
		'''
		.to.deep.equal [
			hello: null
		]

	it 'should interpret multiple words without colon as a key without value', ->
		m.chai.expect parse '''
			hello world
		'''
		.to.deep.equal [
			'hello world': null
		]
