/* 
 * Author      : Anusha Vuyyuru
 * Created On  : 11/21/2016 
 * Descritpion : This batch runs every 2 hours and picks up the subscription that have updated in last 2 hours 
 					and syncs all fields to the open renewal opportunity
 * Test Class : AutoRenewalTest
 * 
 * Changed By : Anusha Vuyyuru
 * Changed On : 5/13/2017
 * Change Log : Modified as per new steelbrick cpq - This runs every hour to see if there're any activated contracts and runs autorenewals process.
 */
 
public with sharing class AutoRenewalBatch implements Database.Batchable<sobject>{
	
	public String query;
    public String conActive = BaseConstants.CONTRACT_ACTIVE_STATUS;
    public String StrBridge = 'Bridge';
    public set<Id> setOfActivatedContracts = new set<Id>();
    
    public AutoRenewalBatch(){
    	query = 'SELECT Id FROM Contract WHERE Status=:conActive AND SBQQ__RenewalForecast__c=false AND SBQQ__Opportunity__c!=null AND CARR__c>=0 AND SBQQ__Opportunity__r.Non_Standard_Deal_Type__c!=:StrBridge';
    }
    
    public AutoRenewalBatch(String query){
    	this.query = query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, list<sobject> scope){
        //Collecting set of contract Ids for which renewal opportunity is going to be created.
        setOfActivatedContracts.addAll(new map<Id, Contract>((list<Contract>)scope).keyset());
    	//Checks the revenue forecast checkbox on contract.
    	Database.update(ContractHelper.createRenewalOpportunities((list<Contract>)scope, null), false);
    }
    
    public void finish(Database.BatchableContext BC){
        //Initiate the batch that runs custom auto renewal process. Batch size 20 is good enough as this process is heavy. Load test at 25 exceeds CPU time limit.
    	Database.executeBatch(new AutoRenewalContinuedBatch(setOfActivatedContracts), 20);
    }
    
}