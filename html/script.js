var timeout = 2500;
var isMenuOpen = false;

$(document).ready(function() {
    window.addEventListener('message', function(event) {
        var data = event.data;

        if (data.type == "openPizza") {
            OpenUi(data);
        } else if (data.type == "closePizza") {
            closeUi();
        } else if (data.type == "showTimer") {
            showTimer(data.time, data.maxTime);
        } else if (data.type == "updateTimer") {
            updateTimer(data.time, data.maxTime);
        } else if (data.type == "hideTimer") {
            hideTimer();
        }
    });

    $(document).on('keydown', function(event) {
        if (event.key === 'Escape') {
            closeUi();
        }
    });
});

// Timer Functions
function showTimer(time, maxTime) {
    const container = $('#timer-container');
    const wrapper = $('.timer-wrapper');
    
    // Set initial values
    updateTimerDisplay(time, maxTime);
    
    // Show with animation
    container.removeClass('hide').addClass('show');
}

function updateTimer(time, maxTime) {
    updateTimerDisplay(time, maxTime);
}

function hideTimer() {
    const container = $('#timer-container');
    
    // Hide with animation
    container.removeClass('show').addClass('hide');
    
    // Remove from DOM after animation
    setTimeout(() => {
        container.removeClass('hide').css('display', 'none');
    }, 500);
}

function updateTimerDisplay(time, maxTime) {
    const minutes = Math.floor(time / 60);
    const seconds = time % 60;
    const timeText = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    
    // Update time text
    $('#timer-text').text(timeText);
    
    // Calculate progress
    const progress = time / maxTime;
    const circumference = 314.16; // Updated for new smaller circle size
    const offset = circumference * (1 - progress);
    
    // Update progress circle
    $('#timer-progress').css('stroke-dashoffset', offset);
    
    // Update colors based on time remaining
    const wrapper = $('.timer-wrapper');
    wrapper.removeClass('timer-green timer-yellow timer-red');
    
    if (time > maxTime * 0.5) {
        wrapper.addClass('timer-green');
        $('#timer-info').text('Plenty of time');
    } else if (time > maxTime * 0.2) {
        wrapper.addClass('timer-yellow');
        $('#timer-info').text('Hurry up');
    } else {
        wrapper.addClass('timer-red');
        $('#timer-info').text('Time running out');
    }
}

// Original Functions
function OpenUi(data) {
    isMenuOpen = true;
    $("#main-container").css('display', 'block').hide().fadeIn(400);
    
    // Update UI elements
    $('#level').text(data.level);
    $('#nextl').text(data.nextIn);
    $('#experience').text(data.exp);
}

function closeUi() {
    $("#main-container").fadeOut(400);
    timeout = setTimeout(function () {
        $("#main-container").css('display', 'none');
        isMenuOpen = false;
        $.post('https://peleg-pizzajob/CloseUi', JSON.stringify({}));
    }, 400);
}

function StartDelivery() {
    $("#main-container").fadeOut(400);
    timeout = setTimeout(function () {
        $("#main-container").html("");
        isMenuOpen = false;
        $.post('https://peleg-pizzajob/Start', JSON.stringify({
          }));
    }, 400);
}
