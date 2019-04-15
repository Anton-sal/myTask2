public class TaskHelper {
    	
	static Integer countAuth = 0;
    
    	//Get access token for authorization
	public static String getAccessToken() {
        final String username = 'junior@twistellar.com';
        final String consumerKey = '3MVG9ZL0ppGP5UrC_fA4fEg8bG1axUdMfFnQAYQhEaH9JxqEsBcIL1uUTsmsvzfOkdXRQNdRRPptBXlWQF.gP';
        final String password = 'bestpass';
        final String consumerSecret = '7571082822679671875';
        
		Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://exs-dev-ed.my.salesforce.com/services/oauth2/token');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setMethod('POST');
        request.setBody('grant_type=password' + '&client_id=' + consumerKey + '&client_secret=' + consumerSecret + '&username=' + username + '&password=' + password);
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        	String token = (String)result.get('access_token');
            return token;
        } else {
          return null;
        }
	}
    	
    	//Get question with GET method 
    public static String getQuestion(String token) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://exs-dev-ed.my.salesforce.com/services/apexrest/vcws');
        request.setHeader('Authorization', 'Bearer '+ token);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
    		return response.getBody();
        } else {
          if (response.getStatusCode() == 401 && TaskHelper.countAuth<3) {
              TaskHelper.getQuestion(TaskHelper.getAccessToken());
              TaskHelper.countAuth++;
              return null;    
          } else {
            if (response.getStatusCode() == 401 && TaskHelper.countAuth == 3) {
                return 'Проблемы с авторизацией!';
            } else return null;
          }
        }
    }
    	
    	//Send answer 
    public static String sendAnswer(String answer, String token) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('https://exs-dev-ed.my.salesforce.com/services/apexrest/vcws');
        request.setHeader('Authorization', 'Bearer '+ token);
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');
        request.setBody('{"Answer":"'+ answer +'"}');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
        	String result = (String)JSON.deserializeUntyped(response.getBody());
        	if (result.indexOf('AccName') != -1) {
          		Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
          		Account newAcc = new Account();
          		Contact newContact = new Contact();
                
				newAcc.Name = (String)resultMap.get('AccName');
                String dateB = (String)resultMap.get('BirthDate');
                Integer year = integer.ValueOf(dateB.substring(0, 4));
                Integer month = integer.ValueOf(dateB.substring(5, 7));
                Integer day = integer.ValueOf(dateB.substring(8, 10));
                Date birth = date.newInstance(year, month, day);
                newContact.Birthdate = birth;
                newContact.FirstName = (String)resultMap.get('FirstName');
            	newContact.LastName = (String)resultMap.get('LastName');

            	insert newAcc;
           		insert newContact;
                
            	String contactUrl = 'https://brave-panda-w36zb6-dev-ed.lightning.force.com/lightning/r/Contact/' + newContact.Id + '/view';
            	return contactUrl;
        	} else {
          	  return  (String)JSON.deserializeUntyped(response.getBody());
        	}
        } else { 
          if (response.getStatusCode() == 400) {
              return 'Неправильный формат ответа!';
          } else {
            if (response.getStatusCode() == 401 && TaskHelper.countAuth < 3) {
            	TaskHelper.sendAnswer(answer, TaskHelper.getAccessToken());
                TaskHelper.countAuth++;
                return null;
            } else {
              if (response.getStatusCode() == 401 && TaskHelper.countAuth == 3) {
                  return 'Проблемы с авторизацией!';
              } else return null;
            }
          }
        } 
	}
}