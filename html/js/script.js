let onDuty = false;
let updateDateTimeInterval;

// Joe was here

const updateDateTime = () => {
    const now = new Date();
    const formattedDate = now.toLocaleString('en-US', {
        month: 'short', day: 'numeric', year: 'numeric',
        hour: '2-digit', minute: '2-digit', second: '2-digit',
        hour12: true
    }).replace(',', '');
    document.getElementById('date-and-time').textContent = formattedDate;
};

window.addEventListener('message', (event) => {
    const { action, playerName, callsign, department } = event.data;

    if (action === "open") {
        document.querySelector('.axonbodycam').classList.remove('hidden');
        onDuty = true;

        const sound = new Audio("https://files.catbox.moe/7fn9t1.mp3");
        sound.volume = 0.2;
        sound.play();
    } 
    
    if (action === "close") {
        document.querySelector('.axonbodycam').classList.add('hidden');
        onDuty = false;
        
        const sound = new Audio("https://files.catbox.moe/7fn9t1.mp3");
        sound.volume = 0.2;
        sound.play();
    }

    if (action === "data") {
        document.getElementById('officer-name').textContent = `${playerName} [${callsign}]`;
        document.getElementById('department').textContent = department;
    }
});

setInterval(updateDateTime, 1000);