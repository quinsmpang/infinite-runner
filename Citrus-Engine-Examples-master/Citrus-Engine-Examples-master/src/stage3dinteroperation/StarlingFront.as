package stage3dinteroperation {

	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.extensions.particles.PDParticleSystem;
	import starling.textures.Texture;

	/**
	 * @author Aymeric
	 */
	public class StarlingFront extends Sprite {
		
		[Embed(source="/../embed/Particle.pex", mimeType="application/octet-stream")]
		private var _particleConfig:Class;

		[Embed(source="/../embed/ParticleTexture.png")]
		private var _particlePng:Class;

		public function StarlingFront() {
			
			var psconfig:XML = new XML(new _particleConfig());
			var psTexture:Texture = Texture.fromBitmap(new _particlePng());

			var particleSystem:PDParticleSystem = new PDParticleSystem(psconfig, psTexture);
			addChild(particleSystem);
			particleSystem.start();
			
			Starling.juggler.add(particleSystem);
			
			particleSystem.x = particleSystem.y = 250;
		}
	}
}
