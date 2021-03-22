return {
  version = "1.4",
  luaversion = "5.1",
  tiledversion = "2020.06.25",
  orientation = "orthogonal",
  renderorder = "left-down",
  width = 64,
  height = 64,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 10,
  nextobjectid = 159,
  properties = {},
  tilesets = {},
  layers = {
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 2,
      name = "level",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      tintcolor = { 85, 170, 255 },
      properties = {},
      objects = {
        {
          id = 23,
          name = "groundA",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 0,
          width = 672,
          height = 288,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 155,
          name = "heightfield",
          type = "",
          shape = "rectangle",
          x = 64,
          y = 112,
          width = 16,
          height = 16,
          rotation = 15,
          visible = true,
          properties = {}
        },
        {
          id = 157,
          name = "box",
          type = "",
          shape = "rectangle",
          x = 96,
          y = 64,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 158,
          name = "cylinder",
          type = "",
          shape = "ellipse",
          x = 32,
          y = 64,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
