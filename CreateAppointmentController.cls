public class CreateAppointmentController {
	public string recId{get;set;} 
    public Lead ld{get;set;}
    public String eventsData{get;set;}
    public String newEventData{get;set;}
    
    public CreateAppointmentController(ApexPages.StandardController stdController) {
        //get current record Id       
        recId = stdController.getId();
        ld=[select firstname,lastname,street,city,state,postalcode,owner.email,owner.phone,owner.firstname,owner.lastname
            from Lead where Id=:recId];
        List<EventWrapper> ewlist=new List<EventWrapper>();
        Integer counter=1;
        for(Event ev:[SELECT Subject, Location, StartDateTime, EndDateTime 
                                FROM Event 
                      where whoId=:ld.Id]){
                          ewlist.add(new EventWrapper(counter++,
                                                      String.valueOf(ev.StartDateTime),
                                                      //.formatGMT('EEE, MMM d yyyy HH:mm:ss'),
                                                      //+' GMT+0530 (India Standard Time)',
                                                      String.valueOf(ev.EndDateTime),
                                                      //.formatGMT('EEE, MMM d yyyy HH:mm:ss'),
                                                      //+' GMT+0530 (India Standard Time)',
                                                      ev.Subject,
                                                     ev.location));
                      }
        String jsString=JSON.serialize(ewlist);
        jsString=jsString.replace('endTime', 'end');
        eventsData=jsString;
    }
    public class EventWrapper{
        public integer id;
        public String start;
        public String endTime;
        public String title;
        public String body;
        public EventWrapper(integer p_id,String p_start,String p_endTime,String p_title,String p_body){
            id=p_id;            
            start=p_start;
            endTime=p_endTime;
            title=p_title;
            body=p_body;
        }
    }
    public void createNewAppointment(){
        System.debug('new appoint with data: '+newEventData);
        if(newEventData.contains('end')){
            newEventData=newEventData.replace('end','endTime');
        }
        EventWrapper ew=(EventWrapper)JSON.deserialize(newEventData, CreateAppointmentController.EventWrapper.class);
        Event ev=new Event();
        ev.subject=ew.title;
        ev.location=ew.body;
        ev.StartDateTime=convertToLocale(ew.start);
        ev.EndDateTime=convertToLocale(ew.endTime);
        ev.whoId=recId;
        try{
        	insert ev;
        }catch(DMLException dex){
            System.debug('Failed to insert: '+dex);
        }
    }
    public DateTime convertToLocale(String str){
        DateTime retval=null;
        DateTime date1;
        try{
            date1=(DateTime)Json.deserialize('"'+str+'"', DateTime.class);
        }catch(Exception ex){
            System.debug('Exception >>> '+ex);
        }
        //convert to user locale
        if(date1!=null){
            String dateformat = 'yyyy-MM-dd HH:mm:ss:sssZ';
            String localdate1 = date1.format(dateformat,''+userinfo.getTimeZone().toString());
            System.debug('localdate1: '+localdate1);
            retval=DateTime.valueOf(localdate1);
            //(DateTime)Json.deserialize('"'+localdate1+'"', DateTime.class);
        }
        return retval;
    }
    public void saveAppointment(){
        //convert lead
        System.debug('save appointment success'); 
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.id);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.debug('lead conversion status: '+lcr.isSuccess());
    }
}