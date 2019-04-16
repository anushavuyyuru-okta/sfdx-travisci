/* 
 * Author      : Anusha Vuyyuru
 * Created On  : 04/11/2019
 * Descritpion : This batch runs after renewal opportunites are created via SBQQ package and then runs our custom autorenewal process
 * Test Class : AutoRenewalTest
 * 
 */

public with sharing class AutoRenewalContinuedBatch implements Database.Batchable<sobject>{
	
	public String query;
    public String conActive = BaseConstants.CONTRACT_ACTIVE_STATUS;
    public set<Id> setOfActivatedContracts = new set<Id>();
    
    public AutoRenewalContinuedBatch(){
        //Query for the contracts where the field SBQQ__RenewalOpportunity__c is populated after the previous batch execution
    	query = 'SELECT Id FROM Contract WHERE SBQQ__RenewalForecast__c=true AND SBQQ__RenewalOpportunity__c!=null AND Id IN :setOfActivatedContracts';
    }
    
    public AutoRenewalContinuedBatch(String query){
    	this.query = query;
    }
    
    public AutoRenewalContinuedBatch(set<Id> setOfActivatedContracts){
    	this();
        this.setOfActivatedContracts = setOfActivatedContracts;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, list<sobject> scope){
         //Set the context to auto renewal opp creation, so owner assignment and other create related fields would calculate
         ContextFlags.renewalsCreation = true;
    	//Updates owner, platform fields and creates OCR, RP related lists
    	AutoRenewal.populateRenewalOpptyFields(new map<Id, Contract>((list<Contract>)scope).keyset());
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
}