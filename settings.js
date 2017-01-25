function settingsClosing(event) {
    if (event.closeAction == event.Action.commit) {
		
		// убираем выделение ошибок
		$('.error').removeClass('error');
		
		var backgroundOpacity =  parseInt($('#backgroundOpacity').val());
		if(isNaN(backgroundOpacity) || backgroundOpacity > 100 || backgroundOpacity < 0) {
			// если backgroundOpacity не число от 0 до 100
			// отменяем закрытие окна настроек
			event.cancel = true;
			// показываем ошибку
			$('#backgroundOpacity').parent().addClass('error');
		}
		
		var backgroundMode = $('#backgroundMode').val();
		
		var showImages = $('#showImages').get(0).checked ? 'yes' : 'no';
			
		// если не было ошибок сохраняем значения
		if(!event.cancel) {	
			System.Gadget.Settings.writeString('backgroundOpacity', backgroundOpacity);
			System.Gadget.Settings.writeString('backgroundMode', backgroundMode);
			System.Gadget.Settings.writeString('showImages', showImages);
		}
    }
}

function main() {
    System.Gadget.onSettingsClosing = settingsClosing;
	
	// считываем старые значения настроек и показываем их в форме
	$('#backgroundOpacity').val(System.Gadget.Settings.readString('backgroundOpacity'));
	$('#backgroundMode').val(System.Gadget.Settings.readString('backgroundMode'));
	$('#showImages').get(0).checked = (System.Gadget.Settings.readString('showImages') == 'yes');
}

$(document).ready(main);