/**
 * New Comment
 */
public with sharing class CustomController {
	public String dateValue {get;set;}
	
	public void save() {
		System.debug('--dateValue-->'+dateValue);
	}
}