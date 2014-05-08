/*
Copyright (c) 2014 Timur Gafarov 

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dmech.shape;

import dlib.math.vector;
import dlib.math.matrix;
import dlib.math.affine;
import dlib.geometry.aabb;

import dmech.geometry;

/*
 * ShapeComponent is a proxy object between RigidBody and Geometry.
 * It stores non-geometric information such as mass contribution,
 * position in body space and a unique identifier for indexing in
 * contact cache.
 */

class ShapeComponent
{
    Geometry geometry; // geometry
    Vector3f centroid; // position in body space
    float mass;        // mass contribution
    uint id = 0;       // global identifier

    Matrix4x4f transformation;

    alias geometry this;

    this(Geometry g, Vector3f c, float m)
    {
        geometry = g;
        centroid = c;
        mass = m;

        transformation = Matrix4x4f.identity;
    }

    // position in world space
    @property Vector3f position()
    {
        return transformation.translation;
    }
/*
    @property GeomSphere asSphere()
    {
        return cast(GeomSphere)geometry;
    }
*/
    @property AABB boundingBox()
    {
        return geometry.boundingBox(
            transformation.translation);
    }
}

