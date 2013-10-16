$(function(){
  
  $('a.read-more').click(function(e){
    $(this).siblings('.read-more-content').addClass('visible');
    $(this).hide();
    e.preventDefault();
  });

});