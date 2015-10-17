// direct narra api is accessible through 'narra' object
//
// narra.width: window width
// narra.height: window height
//
// narra.getProject(): current project
// narra.getItems(): return all project's items
// narra.getItems(synthesizer, item): return project's items in concrete synthesizer scope
// narra.getItem(item): return concrete item
// narra.getJunctions(synthesizer): return junctions in scope of synthesizer
// narra.getJunctions(synthesizer, item): return junctions in scope of synthesizer for concrete item

int canvasWidth = narra.width;
int canvasHeight = narra.height;

void setup() {
  size(canvasWidth, canvasHeight);
}

void draw() {
  background(255);
}