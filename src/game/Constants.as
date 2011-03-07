package game 
{
	/**
	 * ...
	 * @author Santiago Vilar
	 */
	public class Constants 
	{
		public static const GRAVITY:Number = 50;
		
		// Speed constants
		public static const PERON_SPEED_X:Number = 30;
		public static const PLANE_SPEED_X:Number = -150;
		public static const SOLDIER_BULLET_SPEED_X:Number = -50;
		
		// Damage/health constants
			// Peron
		public static const PERON_MAX_HEALTH:Number = 100;		
		public static const LASER_PLANE_DAMAGE:Number = 3;
		
			// Plane
		public static const PLANE_MAX_HEALTH:Number = 100;
		public static const PLANE_BOMB_DAMAGE:Number = 10;
		
			// Cannon
		public static const CANNON_ATTACK_DELAY:Number = 3.0; // seconds
		public static const CANNON_BOMB_DAMAGE:Number = 20;
		public static const CANNON_BOMB_SPEED:Number = 60;	
		
		// Other constants
		public static const LASER_MAX_CHARGE:Number = 5000;
		public static const LASER_CHARGE_STEP:Number = 10;
		public static const LASER_RECHARGE_DELAY:Number = 1.5; // seconds
		
		public static const PLANE_WARNING_X_THRESHOLD:Number = 400; // determines how soon the warning signs appear
	}
}
