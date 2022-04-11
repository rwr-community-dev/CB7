import sys
import xml.etree.ElementTree as XmlET
from pathlib import Path


if __name__ == '__main__':
    if (l := len(sys.argv)) != 3:
        print(f"Error: incorrect number of parameters provided: expected 2, got {l-1}")
        sys.exit(1)

    xml_fp = Path(sys.argv[1])
    if not xml_fp.exists():
        print(f"Error: no file found at '{xml_fp}'")
        sys.exit(2)

    try:
        scale_factor = float(sys.argv[2])
    except ValueError:
        print(f"Error: conversion of '{sys.argv[2]}' to float failed")
        sys.exit(3)

    with xml_fp.open(mode="r", encoding="UTF-8") as f:
        xml_str = f.read()

    print("Loading mesh XML...")
    mesh_xml = XmlET.fromstring(xml_str)

    print("Finding vertices...  ", end="")
    vertices = mesh_xml.findall("./sharedgeometry/vertexbuffer/vertex")
    print(f"{len(vertices)} found")

    print(f"Scaling vertex positions by {scale_factor}...")
    for vertex in vertices:
        position = vertex.find("position")
        for dimension, float_value_str in position.attrib.items():
            position.attrib[dimension] = str(float(float_value_str) * scale_factor)

    xml_fpo = xml_fp.parent / f"{xml_fp.stem}_scaled{xml_fp.suffix}"
    print(f"Writing scaled mesh to '{xml_fpo}'")
    xml_s = XmlET.tostring(mesh_xml, encoding="unicode")
    with xml_fpo.open(mode="w", encoding="UTF-8") as f:
        f.write(xml_s)
