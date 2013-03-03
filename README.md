CCBox2D-Physics - force directed layout algorithm using physics engine
============

This project is a work in progress to port Ed Preston's PSArborTouch into Box2D physics engine.

https://github.com/epreston/PSArborTouch
"PSArborTouch is a particle / spring physics engine optimised for 2D content layout and eye-catching visual effects.
The goal of PSArborTouch is to build a high-quality physics based graph layout engine designed specifically for the Mac OSX and iOS. 
The inspiration / structure comes from arbor, a dynamic and well structured javascript engine for the same purpose."

The project features Barnes Hut Repulsion / Attraction sample with physics engine integration.

Instructions
============
clone repo
run pod install


Podfile
============
	platform :ios, '5.0'

	# Using the Default
	pod 'box2d'
	pod 'cocos2d'
	pod 'CCBox2D' , :podspec => 'https://raw.github.com/jdp-global/CCBox2D/master/CCBox2D.podspec'


Useful links
http://arborjs.org/
http://arborjs.org/docs/barnes-hut
http://murderandcreate.com/physics/
http://www.cs.princeton.edu/courses/archive/fall03/cs126/assignments/barnes-hut.html
http://arxiv.org/abs/1209.0748
http://arxiv.org/pdf/1201.3011v1.pdf
http://www.kickstarter.com/projects/shiffman/the-nature-of-code-book-project
http://natureofcode.com/book/chapter-2-forces/
http://natureofcode.com/book/chapter-5-physics-libraries/



