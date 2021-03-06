/**
 * RollupHelper_Test
 * @see https://gist.github.com/grotib/838a40928d17d241f974319f04336bc3/edit
 * 
 * @version 1.0
 * @author Thibault Weber - SYNEFO
 */
@isTest
private class RollupHelper_Test {

	private static testMethod void testRollupHelper() {

		Account acc = new Account(Name = 'Synefo');
		insert acc;
		
		List<Contact> contacts = new List<Contact>{new Contact(LastName = 'test1', AccountId = acc.Id),
													new Contact(LastName = 'test2', AccountId = acc.Id),
													new Contact(LastName = 'test3', AccountId = acc.Id, DoNotCall = true)
		};
		
		insert contacts;
		
		Test.startTest();
		
			RollupHelper rolls = new RollupHelper(contacts, Contact.AccountId);
	
			RollupHelper.Rollup countRollup = new RollupHelper.Rollup(Account.NumberOfEmployees);
			countRollup.addFilter(Contact.DoNotCall, RollupHelper.Operator.NOT_EQ, false);
			rolls.addRollup(countRollup);
			
			
			RollupHelper.Rollup concatRollup = new RollupHelper.Rollup(Account.Description, RollupHelper.Aggregation.CONCAT, Contact.LastName, ' - ', 'LastName');
			concatRollup.addFilter(Contact.DoNotCall, RollupHelper.Operator.EQ, false);
			rolls.addRollup(concatRollup);
			
			
			RollupHelper.Rollup maxRollup = new RollupHelper.Rollup(Account.Name, RollupHelper.Aggregation.MAX, Contact.LastName);
			maxRollup.addFilter(Contact.LastName, RollupHelper.Operator.CONTAINS, 'test');
			rolls.addRollup(maxRollup);
	
			RollupHelper.Rollup minRollup = new RollupHelper.Rollup(Account.AccountNumber, RollupHelper.Aggregation.MIN, Contact.LastName);
			minRollup.addFilter(Contact.LastName, RollupHelper.Operator.NOT_CONTAINS, 'abcd');
			rolls.addRollup(minRollup);
	
	
			rolls.process();
		
		Test.stopTest();
		
		acc = [SELECT Id, Name, AccountNumber, NumberOfEmployees, Description FROM Account WHERE Id = :acc.Id][0];
		
		
		system.assertEquals(1, acc.NumberOfEmployees);
		system.assertEquals('test1 - test2', acc.Description);
		system.assertEquals('test3', acc.Name);
		system.assertEquals('test1', acc.AccountNumber);
	}

}