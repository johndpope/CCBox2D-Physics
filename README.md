CCBox2D-Physics
============

This project is a work in progress to port Ed Preston's PSArborTouch into Box2D physics engine.

https://github.com/epreston/PSArborTouch
PSArborTouch is a particle / spring physics engine optimised for 2D content layout and eye-catching visual effects.
The goal of PSArborTouch is to build a high-quality physics based graph layout engine designed specifically for the Mac OSX and iOS. 
The inspiration / structure comes from arbor, a dynamic and well structured javascript engine for the same purpose.

The project includes Barnes Hut Repulsion / Attraction sample.


Podfile
============
	platform :ios, '5.0'

	# Using the Default
	pod 'box2d'
	pod 'cocos2d'
	pod 'CCBox2D' , :podspec => 'https://raw.github.com/jdp-global/CCBox2D/master/CCBox2D.podspec'



