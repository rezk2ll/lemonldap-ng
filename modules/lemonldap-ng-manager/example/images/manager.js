var simpleTreeCollection;
$(document).ready(function(){
simpleTreeCollection = $(".simpleTree").simpleTree({
    autoclose: false,
    drag: false,
    afterClick:function(node){
        var span=$('span:first',node);
        $('#help').load(scriptname+'?help='+span.attr('help'));
    },
    afterDblClick:function(node){
    //alert("text-"+$("span:first",node).text());
    },
    afterMove:function(destination, source, pos){
    //alert("destination-"+$("span:first",destination).text()+" source-"+$("span:first",source).text()+" pos-"+pos);
    },
    afterAjax:function() {
    //alert("Loaded");
    },
    animate:true
    //,docToFolderConvert:true
    });
  var w=xClientWidth()-12;
  var h=xClientHeight()-12;
  //var h=window.outerHeight;
  s32=new xSplitter('idSplitter32',0,0,0,0,false,6,h/2,h/8,h/8,true,0);
  s3=new xSplitter('idSplitter3',0,0,w,h,true,6,w/4,w/8,w/8,true,4,null,s32);
  xAddEventListener(window,'resize',win_onresize,false);
}
);
var currentId;
function win_onresize(){
  var w=xClientWidth()-12;
  var h=xClientHeight()-12;
  s3.paint(w,h,w/4,w/5);
}
function lmtext(id){
  return $('#text_'+id).attr('name');
}
function lmdata(id){
  return $('#text_'+id).attr('value');
}
function lmparent(id){
  return $('#'+id).parent().parent().attr('id');
}
function setlmtext(id,v){
  if(v.length==0){
    alert("Null value");
  }
  else {
  $('#text_'+id).attr('name',v);
  $('#text_'+id).text(v);
  }
}
function setlmdata(id,v){
  $('#text_'+id).attr('value',v);
}
function display(div,title) {
  var divs=$('#content').children();
  divs.toggleClass('hidden',true);
  divs.removeClass('content');
  $('#content_'+div).removeClass('hidden');
  $('#content_'+div).addClass('content');
  $('#content_title').html(title);
  $('#newkb,#newrb,#delkb,#newkbr,#newrbr').css('display','none');
}
function none(id) {
  display('default','Lemonldap::NG Manager');
}
function hashRoot(){
  currentId=simpleTreeCollection[0].getSelected().attr('id');
  alert(currentId);
  display('default','Lemonldap::NG Manager');
  $('#newkbr').css('display','block');
}
function btext(id) {
  currentId=id;
  $('#btextKey').attr('value',lmtext(id));
  $('#btextValue').attr('value',lmdata(id));
  display('btext','Clef');
  $('#newkb,#delkb').css('display','block');
}
function int(id) {
  currentId=id;
  $('#int').attr('value',lmdata(id));
  display('int',lmtext(id));
}
function text(id) {
  currentId=id;
  $('#text').attr('value',lmdata(id));
  display('text',lmtext(id));
}
function securedCookieValues(id){
  currentId=id;
  $('#securedCookie'+lmdata(id)).attr('checked',1);
  display('securedCookie',lmtext(id));
}
function rules(id){
  currentId=id;
  var t=lmtext(id);
  $('#rulKey').attr('value',lmtext(id));
  $('#rulValue').attr('value',lmdata(id));
  display('rules',lmtext(lmparent(id)));
  if(t=='default'){$('#rulKey').attr('readonly','readonly')}
  else{
    $('#rulKey').attr('readonly','');
    $('#delkb').css('display','block')
  }
  $('#newrb').css('display','block');
}
function rulesRoot(id){
  display('default','Lemonldap::NG Manager');
  $('#newrbr').css('display','block');
}
var count=0;
var text4newKey='Key';
var value4newKey='Value';
function newId(c){
  count++;
  c=c.replace(/^NewID_(.*)_\d+$/,'$1');
  return 'NewID_'+c+'_'+count;
}
function newKeyR(){
  var newIdValue=newId(currentId);
  simpleTreeCollection[0].addNode(newIdValue,text4newKey,function(d,s){
    $('>span',s).attr('onClick','btext("'+newIdValue+'")').attr('name',text4newKey).attr('value',value4newKey).attr('id','text_'+newIdValue);
    btext(newIdValue);
  });
  return false;
}
function newKey(){
  var newIdValue=newId(currentId);
  simpleTreeCollection[0].newNodeAfter(newIdValue,text4newKey,function(d,s){
    $('>span',s).attr('onClick','btext("'+newIdValue+'")').attr('name',text4newKey).attr('value',value4newKey).attr('id','text_'+newIdValue);
    btext(newIdValue);
  });
  return false;
}
function newRule(){
  var newIdValue=newId(currentId);
  simpleTreeCollection[0].newNodeAfter(newIdValue,text4newKey,function(d,s){
    $('>span',s).attr('onClick','rules("'+newIdValue+'")').attr('name',text4newKey).attr('value',value4newKey).attr('id','text_'+newIdValue);
    rules(newIdValue);
    });
  return false;
}
function delKey(){
  $('#'+currentId).prev().remove();
  $('#'+currentId).remove();
}
