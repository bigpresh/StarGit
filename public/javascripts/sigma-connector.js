// --- SiGMa (API version) JavaSCript connector ---
// Contains the functions to send data to a SiGMa.swf instance.

// You have to initialize this parameter before using the
// different functions:
var sigmaDOM;
var outputFunction;

// This function starts the layout algorithm:
function initForceAtlas(){
  try{
    sigmaDOM.initForceAtlas();
  }catch(e){
    if(outputFunction){
      outputFunction(e.description);
    }
  } 
}

// This function stops the layout algorithm:
function killForceAtlas(){
  try{
    sigmaDOM.killForceAtlas();
  }catch(e){
    if(outputFunction){
      outputFunction(e.description);
    }
  } 
}

// This function delete the whole graph in SiGMa:
function deleteGraph(){
  try{
    sigmaDOM.deleteGraph();
  }catch(e){
    if(outputFunction){
      outputFunction(e.description);
    }
  } 
}

// This function pushes each non-existing node and edge in the graph,
// and removes the ones that were in SiGMa:
function updateGraph(graph){
  try{
    sigmaDOM.updateGraph(graph);
  }catch(e){
    if(outputFunction){
      outputFunction(e.description);
    }
  } 
}

// This function pushes each non-existing node and edge in the graph,
// and updates the ones that are already in SiGMa:
function pushGraph(graph){
  try{
    sigmaDOM.pushGraph(graph);
  }catch(e){
    if(outputFunction){
      outputFunction(e.description);
    }
  } 
}

// This function activates the fish-eye zoom:
function activateFishEye(){
  try{
    sigmaDOM.activateFishEye();
  }catch(e){
    if(outputFunction){
      outputFunction(e.description);
    }
  } 
}

// This function desactivates the fish-eye zoom:
function deactivateFishEye(){
  try{
    sigmaDOM.deactivateFishEye();
  }catch(e){
    if(outputFunction){
      outputFunction(e.description);
    }
  } 
}

// This function sets the color of the nodes relatively to one
// attribute:
function setColor(field,attributes){
  try{
    sigmaDOM.setColor(field,attributes);
  }catch(e){
    if(outputFunction){
      outputFunction(e.description);
    }
  } 
}

// This function sets the color of the nodes relatively to one
// attribute:
function setSize(field){
  try{
    sigmaDOM.setSize(field);
  }catch(e){
    if(outputFunction){
      outputFunction(e.description);
    }
  } 
}

// This function recenters the graph in SiGMa (basically, it
// cancels each zooming action and every drag'n'drop):
function recenterGraph(){
  try{
    sigmaDOM.resetGraphPosition();
  }catch(e){
    if(outputFunction){
      outputFunction(e.description);
    }
  } 
}

// /!\ This script is just a draft, most of the methods might change
//     soon, and a lot of missing features are already in development...
