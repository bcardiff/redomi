window.lastMouse = {clientX: 0, clientY: 0};

function trackMouse() {
  document.onmousemove = function(e){
    window.lastMouse.clientX = e.clientX;
    window.lastMouse.clientY = e.clientY;
    console.log("mouse location:", window.lastMouse);
  };
}
