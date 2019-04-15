public class TaskController {
    
    public String answer {get; set;}
 	public String question {get; set;}
    public String recomedations {get; set;}
    public String accLink {get; set;}
    public String accName {get; set;}
    public Boolean displayPopup {get; set;}
 	String token;
    
    public void getQuest() {
    	token = TaskHelper.getAccessToken();
    	question = TaskHelper.getQuestion(token);
    }
    
    public void sendAnsw() {
        if (question != null) {
      		String response = TaskHelper.sendAnswer(answer, token);
      		String typeRequest = response.substring(0,5);
            
        	if (typeRequest.equals('https')) {
            	accLink = response;
            	accName = 'Новый контакт успешно создан. Нажмите здесь для просмотра контакта!';
        	} else { 
        	  recomedations = response;  
        	  displayPopup = true;    
        	  }
        } else {
          recomedations = 'Ты еще не видел вопрос! Посмотри вопрос!';  
          displayPopup = true;
        }
    }
    
    public void closePopup() {
        displayPopup = false;
    }
}