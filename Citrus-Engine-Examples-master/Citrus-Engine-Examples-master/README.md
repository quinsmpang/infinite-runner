[Get the full engine here](https://github.com/alamboley/Citrus-Engine). Be careful examples are update with the last code version on the Citrus Engine's GitHub. It may have differences with the SWCs build.

![](http://aymericlamboley.fr/blog/wp-content/uploads/2012/11/citrus-logo-2D.png)

The [Citrus Engine](http://citrusengine.com/) is a professional-grade, scalable Flash game engine built for industry-quality games. It is built upon modern Flash programming practices, allowing you to focus on making your game awesome! It comes built-in with a "platformer" starter-kit, which you can use to easily make awesome 2D or 3D sidescrolling games.

The [Citrus Engine](http://citrusengine.com/) is not only made for platformer games, but for all type of games. It offers a nice way to separate logic/physics from art.

It offers many options, you may use :
- select between : the classic flash display list, blitting, [Starling](http://gamua.com/starling/) (including [Feathers](http://feathersui.com/)) and [Away3D](http://away3d.com/).
- select between : [Box2D](http://www.box2d.org/manual.html), [Nape](http://napephys.com/), [AwayPhysics](https://github.com/away3d/awayphysics-core-fp11) and a Simple math based collision detection.
- a simple way to manage object creation, and for advanced developers : an entity/component system and object pooling.
- a LevelManager and a LoadManager which may use Flash Pro as a level editor.
- a Console, Sound management class, Keyboard and input handler...

Games References
----------------
[![Jim loves Mary](http://aymericlamboley.fr/blog/wp-content/uploads/2013/04/jim-mary.png)](http://meowbeast.com/game/jim-loves-mary/)
[![Chorizos de España](http://aymericlamboley.fr/blog/wp-content/uploads/2013/03/Chorizos.png)](https://play.google.com/store/apps/details?id=air.com.ravalmatic.ChorizosDeEspana)
[![Shotgun vs Zombies](http://aymericlamboley.fr/blog/wp-content/uploads/2013/03/Shotgun-vs-Zombies.png)](http://armorgames.com/play/14737/shotgun-vs-zombies)
[![Gérard](http://aymericlamboley.fr/blog/wp-content/uploads/2013/02/gerard.png)](https://play.google.com/store/apps/details?id=air.com.studio3wg.gerard)
[![Santa Rush](http://aymericlamboley.fr/blog/wp-content/uploads/2012/12/Santa Rush.png)](https://play.google.com/store/apps/details?id=air.com.studio3wg.SantaRush)
[![Kepher](http://aymericlamboley.fr/blog/wp-content/uploads/2012/12/Kepher.png)](http://www.daarboven.net/kepher_comingsoon.html)
[![Stack of Defence](http://aymericlamboley.fr/blog/wp-content/uploads/2012/11/stackofdefence.png)](http://www.newgrounds.com/portal/view/606457)
[![Music Game](http://aymericlamboley.fr/blog/wp-content/uploads/2012/11/cynic.png)](http://cynicmusic.com/citrus/)
[![Les aventures d'Aïcha - l'odyssée des 4 mondes](http://aymericlamboley.fr/blog/wp-content/uploads/2012/11/Aicha.png)](https://www.facebook.com/aichaetvous/app_449473045088858)
[![Escape From Nerd Factory](http://aymericlamboley.fr/blog/wp-content/uploads/2012/09/escape-from-nerd-factory.jpg)](http://www.newgrounds.com/portal/view/598677)
[![Kinessia](http://aymericlamboley.fr/blog/wp-content/uploads/2012/08/Kinessia.jpg)](http://kinessia.aymericlamboley.fr/)
[![MarcoPoloWeltrennen](http://aymericlamboley.fr/blog/wp-content/uploads/2012/08/MarcoPoloWeltrennen.png)](http://www.marcopoloweltrennen.de/)
[![Tibi](http://aymericlamboley.fr/blog/wp-content/uploads/2012/09/Tibi.png)](http://hellorepublic.com/client/tibi/platform/)

Project Setup
-------------
- bin : pictures, animations, levels, ... loaded at runtime.
- embed : embedded assets (e.g. fonts, pictures, texture atlas, ...).
- fla : two levels used in the box2dstarling demo, and two animate characters in two versions one for SpriteArt and one for StarlingArt thanks to the DynamicTextureAtlas class (loaded at runtime).
- lib : the different swcs used by some demo.
- src : different demos ready to use! You just need to copy & paste the Main from the package you want into the src/Main.as and the demo will run. Be careful with package & import.

[API](http://citrusengine.com/api/)
