import sys
import xml.etree.ElementTree as XmlET
from pathlib import Path
from statistics import fmean


if __name__ == '__main__':
    if (l := len(sys.argv)) != 2:
        print(f"Error: incorrect number of parameters provided: expected 1, got {l-1}")
        sys.exit(1)

    xml_fp = Path(sys.argv[1])
    if not xml_fp.exists():
        print(f"Error: no file found at '{xml_fp}'")
        sys.exit(2)

    with xml_fp.open(mode="r", encoding="UTF-8") as f:
        xml_str = f.read()

    print("Loading voxel XML...")
    mesh_xml = XmlET.fromstring(xml_str)

    print("Discovering voxels... ", end="")
    voxels = mesh_xml.findall("./voxels/voxel")
    print(f"{len(voxels)} found!")

    voxel_colours = []
    for voxel in voxels:
        r, g, b = voxel.attrib["r"], voxel.attrib["g"], voxel.attrib["b"]
        voxel_colours.append({"r": float(r), "g": float(g), "b": float(b)})

    # calculate average colour(s)
    avg_r = fmean([voxel_colour["r"] for voxel_colour in voxel_colours])
    avg_g = fmean([voxel_colour["g"] for voxel_colour in voxel_colours])
    avg_b = fmean([voxel_colour["b"] for voxel_colour in voxel_colours])
    ar255, ag255, ab255 = round(avg_r * 255), round(avg_g * 255), round(avg_b * 255)
    print(f"Average: R={avg_r:.3f}|{ar255}, G={avg_g:.3f}|{ag255}, B={avg_b:.3f}|{ab255}")

    user_response = input("Target colour [R G B]: ")
    str_colours = user_response.split()
    if not len(str_colours) == 3:
        print(f"Error: must specify RGB, e.g. 255 255 255")
        sys.exit(3)

    try:
        tr, tg, tb = int(str_colours[0]), int(str_colours[1]), int(str_colours[2])
    except ValueError as e:
        print(f"Error: must specify RGB, e.g. 255 255 255")
        sys.exit(4)

    if tr < 0 or tr > 255:
        print(f"Error: R not within 0-255")
        sys.exit(5)
    if tg < 0 or tg > 255:
        print(f"Error: G not within 0-255")
        sys.exit(5)
    if tb < 0 or tb > 255:
        print(f"Error: B not within 0-255")
        sys.exit(5)

    diff_r, diff_g, diff_b = tr - ar255, tg - ag255, tb - ab255
    print(f"Difference: R={diff_r}, G={diff_g}, B={diff_b}")

    drf, dgf, dbf = diff_r / 255, diff_g / 255, diff_b / 255
    for voxel, colour in zip(voxels, voxel_colours):
        # calculate shifted colours, clamp within 0.0-1.0, and convert to str
        voxel.attrib["r"] = f"{min(max(0.0, colour['r'] + drf), 1.0):.4f}"
        voxel.attrib["g"] = f"{min(max(0.0, colour['g'] + dgf), 1.0):.4f}"
        voxel.attrib["b"] = f"{min(max(0.0, colour['b'] + dbf), 1.0):.4f}"

    xml_fpo = xml_fp.parent / f"{xml_fp.stem}_recolour{xml_fp.suffix}"
    print(f"Writing recoloured voxel model to '{xml_fpo}'")
    xml_s = XmlET.tostring(mesh_xml, encoding="unicode")
    with xml_fpo.open(mode="w", encoding="UTF-8") as f:
        f.write(xml_s)
