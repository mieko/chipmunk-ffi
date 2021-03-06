require File.dirname(__FILE__)+'/spec_helper'
describe 'ShapeStruct in chipmunk' do
  describe 'Circle class' do
    it 'can be created' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 40, CP::ZERO_VEC_2
    end

    it 'can get its body' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 20, CP::ZERO_VEC_2
      s.body.should == bod
    end

    it 'can get its elasticity' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 20, CP::ZERO_VEC_2
      s.e.should == 0
      s.e = 0.5
      s.e.should == 0.5
    end

    it 'can build a BB' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 40, CP::ZERO_VEC_2
      bb = s.bb
      bb.should_not be_nil
      bb.l.should == -40 
      bb.b.should == -40
      bb.r.should == 40
      bb.t.should == 40
    end

    it 'can get its layers' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 40, CP::ZERO_VEC_2
      # he sets layers to -1 on an unsigned int
      s.layers.should == 2**32-1
    end

    it 'can get its group' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 40, CP::ZERO_VEC_2
      s.struct.group.should == 0
    end

    it 'can get its col type' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 40, CP::ZERO_VEC_2
      s.collision_type.should == nil
      s.collision_type = :foo
      s.collision_type.should == :foo
      s.struct.collision_type.should == :foo.object_id
    end

    it 'can get its sensor' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 40, CP::ZERO_VEC_2
      s.sensor?.should be_false
      s.sensor = true
      s.sensor?.should be_true
    end

    it 'can get its u' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 40, CP::ZERO_VEC_2
      s.u.should be_close(0,0.001)
    end

    it 'can get its surf vec' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 40, CP::ZERO_VEC_2
      s.surface_v = vec2(4,5)
      s.surface_v.x.should be_close(4,0.001)
      s.surface_v.y.should be_close(5,0.001)
    end

    it 'can get its data' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 40, CP::ZERO_VEC_2
      s.data.read_long.should == s.object_id
    end

    it 'can get its klass' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 40, CP::ZERO_VEC_2
      ShapeClassStruct.new(s.struct.klass).type.should == :circle_shape
    end

    it 'can set its bodys v' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 20, CP::ZERO_VEC_2
      s.body.v = vec2(4,5)
    end

    it 'can set its sensory-ness' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 20, CP::ZERO_VEC_2
      s.sensor?.should be_false
      s.sensor = true
      s.sensor?.should be_true
    end

    it 'can query if a point hits it' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 20, CP::ZERO_VEC_2
      s.point_query(vec2(0,10)).should be_true
      s.point_query(vec2(0,100)).should be_false
    end

    it 'can query if a segment hits it' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Circle.new bod, 20, CP::ZERO_VEC_2
      info = s.segment_query(vec2(-100,10),vec2(0,10))
      GC.start
      info.hit.should be_true
      info.t.should be_close(0.827,0.001)
      info.n.x.should be_close(-0.866, 0.001)
      info.n.y.should be_close(0.5, 0.001)
    end
  end

  describe 'Segment class' do
    it 'can be created' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Segment.new bod, vec2(1,1), vec2(2,2), 5
    end
  end
  describe 'Poly class' do
    it 'can be created' do
      bod = CP::Body.new 90, 76
      s = CP::Shape::Poly.new bod, [vec2(0,0), vec2(1,-1),vec2(-1,-1)], CP::ZERO_VEC_2
    end
    
    it 'can strictly validate vertices' do
      verts = [
       vec2(-1,-1),
       vec2(-1, 1),
       vec2( 1, 1),
       vec2( 1,-1)
      ]
      CP::Shape::Poly.strictly_valid_vertices?(verts).should be true
      CP::Shape::Poly.strictly_valid_vertices?(verts.reverse).should be false
      
      verts = [
        vec2(-1,-1),
        vec2( 1,-1),
        vec2( 0, 0), # Bad vert!
        vec2( 1, 1),
        vec2(-1, 1)
      ]
      CP::Shape::Poly.strictly_valid_vertices?(verts).should be false
    end
    
    it 'can loosely validate vertices' do
      verts = [
       vec2(-1,-1),
       vec2(-1, 1),
       vec2( 1, 1),
       vec2( 1,-1)
      ]
      CP::Shape::Poly.valid_vertices?(verts).should be true
      CP::Shape::Poly.valid_vertices?(verts.reverse).should be true
      
      verts = [
        vec2(-1,-1),
        vec2( 1,-1),
        vec2( 0, 0), # Bad vert!
        vec2( 1, 1),
        vec2(-1, 1)
      ]
      CP::Shape::Poly.valid_vertices?(verts).should be false
    
    end
    
    it 'accepts convex polygons with either winding' do
      bod = CP::Body.new 90, 76
      verts = [
       vec2(-1,-1),
       vec2(-1, 1),
       vec2( 1, 1),
       vec2( 1,-1)
      ]
      CP::Shape::Poly.new(bod,verts,CP::ZERO_VEC_2)
      CP::Shape::Poly.new(bod,verts.reverse,CP::ZERO_VEC_2)
    end
    
    it 'rejects concave polygons' do
      bod = CP::Body.new 90, 76
      verts = [
        vec2(-1,-1),
        vec2( 1,-1),
        vec2( 0, 0), # Bad vert!
        vec2( 1, 1),
        vec2(-1, 1)
      ]
      lambda { CP::Shape::Poly.new(bod,verts,CP::ZERO_VEC_2) }.should raise_error
    end
  end


end
