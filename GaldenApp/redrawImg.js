function redrawImg(obj,img){
	obj.fadeOut(200,function(){
		obj.attr('src',img);
		obj.attr('onclick', 'window.webkit.messageHandlers.imageView.postMessage(\''+img+'\')')
	}).fadeIn(200);
}
