function dockStateChanged() {
    if (System.Gadget.docked) {
		var width = '130px';
		var height = '145px';
	
		$('#background').css('width', width)
						.css('height', height)
						.attr('src', 'images/dockedBg.png');
	
        $(document.body).removeClass('undocked')
						.addClass('docked')
						.css('width', width)
						.css('height', height);
    } else {
		var width = '260px';
		var height = '240px';
		
		$('#background').css('width', width)
						.css('height', height)
						.attr('src', 'images/undockedBg.png');

        $(document.body).removeClass('docked')
						.addClass('undocked')
						.css('width', width)
						.css('height', height);
    }
	
	draw();
}

function onSettingsClosed(e) {
	if (e.closeAction == e.Action.commit) {
        draw();
    }
}

function draw() {
	// в IE эта строка не обязательна, но для ясности
	var background = $('#background').get(0);

	// удаляем фоновые объекты
	background.removeObjects();
	
	// на undocked гаджете помещается побольше объектов
	if(!System.Gadget.docked) {
		// фон
		var backgroundMode = System.Gadget.Settings.readString('backgroundMode');
		var backgroundOpacity = System.Gadget.Settings.readString('backgroundOpacity');

		switch (backgroundMode) {
			case 'gtextRotation':
				for(var i = 0; i < 360; i+=72) {
					var text = background.addTextObject(strings.rotation, 'Arial', 25, 'white', 135, 125);
					text.rotation = i;
					text.opacity = backgroundOpacity;
				}
				break;
			case 'gtextBlur':
				for(var j = 0, y = 30, b = 0; j < 4; j++, y += 50, b += 2) {
					var text = background.addTextObject(strings.blur, 'Arial', 30, 'white', 135, y);
					text.blur = b;		
					text.align = 1; //align center
					text.opacity = backgroundOpacity;
				}
				break;
			case 'gimageBlur':
				for(var j = 0, y = 30, b = 0; j < 4; j++, y += 50, b += 2) {
					var image = background.addImageObject('images/arrow.png', 10, y);
					image.blur = b;
					image.opacity = backgroundOpacity;
				}
				break;
			case 'gimageRotation':
				for(var i = 0; i < 360; i+=30) {
					var image = background.addImageObject('images/arrow.png', 135-86, 125-19);
					image.rotation = i;
					image.opacity = backgroundOpacity;
				}
				break;
		}
	}
	
    
	//if(System.Gadget.Settings.readString('showImages') == 'yes' && !System.Gadget.docked) {
		$('#icons').hide();
		$('#thumbnail').show();
	//} else {
	//	$('#icons').hide();
	//	$('#thumbnail').hide();			
	//}
}

function addIcons() {
	var files = [
		System.Gadget.path + '\\gadget.xml',
		System.Gadget.path + '\\main.html',
		System.Gadget.path + '\\main.css',
		System.Gadget.path + '\\main.js',
		'C:\\Windows\\System32\\calc.exe',
		'C:\\Program Files\\Windows Sidebar\\sidebar.exe'
	];
	
	var icons = $('#icons').get(0);
	
	for(var i in files) {
		var icon = new Image();
		icon.src = 'gimage:///' + files[i] + '?width=32&height=32';
		icons.appendChild(icon);
	}
}

function initSettings() {
    System.Gadget.settingsUI = 'settings.html';
    System.Gadget.onSettingsClosed = onSettingsClosed;

	// устанавливаем значения по умолчанию при первом запуске гаджета
	var backgroundOpacity = System.Gadget.Settings.readString('backgroundOpacity');
	if(backgroundOpacity == '') {
		System.Gadget.Settings.writeString('backgroundOpacity', '15');
	}
	
	var backgroundMode = System.Gadget.Settings.readString('backgroundMode');
	if(backgroundMode == '') {
		System.Gadget.Settings.writeString('backgroundMode', 'gtextRotation');
	}
	
	var showImages = System.Gadget.Settings.readString('showImages');
	if(showImages == '') {
		System.Gadget.Settings.writeString('showImages', 'no');
	}
}

function onFlyoutShow() {
	$('#toggle-flyout').text(strings.hideFlyout);
	
	try {
		var fd = System.Gadget.Flyout.document;
		fd.getElementById('header').innerHTML = strings.flyoutHeader;
		fd.getElementById('description').innerHTML = strings.flyoutDescription;
	} catch(e) {
	
	}
}

function onFlyoutHide() {
	$('#toggle-flyout').text(strings.showFlyout);
}

function initFlyout() {
	System.Gadget.Flyout.file = 'flyout.html';
	System.Gadget.Flyout.onShow = onFlyoutShow;
	System.Gadget.Flyout.onHide = onFlyoutHide;

	$('#toggle-flyout').text(strings.showFlyout);

	// открываем и закрываем флайаут
	$('#toggle-flyout').get(0).onclick = function() {
		System.Gadget.Flyout.show = !System.Gadget.Flyout.show;
		return false;
	}
}

// рыба 
function showInfo() {
	// занятая память
	$('#memory').text(System.Machine.totalMemory - System.Machine.availableMemory);

	// суммарная загрузка CPU
	var CPUs = System.Machine.CPUs;
	var p = 0;
    for (var i = 0; i < CPUs.count; i++) {
        p += CPUs.item(i).usagePercentage;
    }	
	$('#CPU').text(Math.round(p / CPUs.count));
	
	setTimeout(showInfo, 1000);
}

function main() {
	initSettings();
	initFlyout();
	showInfo();
	addIcons();

    System.Gadget.onDock = dockStateChanged;
    System.Gadget.onUndock = dockStateChanged;
    dockStateChanged();
}

$(document).ready(main);