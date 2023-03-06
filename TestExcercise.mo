package TestExcercise

  package Types
  
  type Pressure = Modelica.Units.SI.AbsolutePressure(min=0, max=1e8);
  type Temperature = Modelica.Units.SI.Temperature(min=-1+273.15, max=100+273.15);
  type Enthalpy = Modelica.Units.SI.SpecificEnthalpy(min=-1e10, max=1e10);
  
  end Types; 
package Media 
partial package PartialMedium
      extends Types;
      constant Pressure p0, pref;
      constant Temperature T0 = 300, Tref = 273.15;
      constant Enthalpy h0 = enthalpy(state_pT(p0, T0));

      record ThermodynamicState
        Pressure p;
        Temperature T;
      end ThermodynamicState;

      replaceable partial function enthalpy
        input ThermodynamicState state;
        output Enthalpy h;
      end enthalpy;

      replaceable function state_pT
        input Pressure p;
        input Temperature T;
        output ThermodynamicState state;
      algorithm
        state := ThermodynamicState(p = p, T = T);
      end state_pT;
     type MassFlow = Modelica.Units.SI.MassFlowRate;

    end PartialMedium;

    package Water
    extends PartialMedium(T0 = 298, Tref = 273.15, p0=1e5, pref=1e5, Pressure(start=p0));
    
    constant Modelica.Units.SI.SpecificHeatCapacityAtConstantPressure cp;
    
    redeclare function extends enthalpy
    algorithm
    h := cp*(state.T - Tref);
    end enthalpy;
    
    end Water;
  end Media;

  package Interfaces
    connector Port
replaceable package Medium = Media.PartialMedium;
    
    Medium.Pressure p;
    flow Medium.MassFlow m_flow;
    stream Medium.Enthalpy h_outflow;
  annotation(
        Icon(graphics = {Ellipse(fillColor = {0, 0, 255}, fillPattern = FillPattern.Solid, extent = {{-94, 94}, {94, -94}})}));
    
    end Port;
    
    partial model BaseSource
      replaceable package Medium = Media.PartialMedium;
      Modelica.Blocks.Interfaces.RealInput set annotation(
        Placement(visible = true, transformation(origin = {-110, 50}, extent = {{-20, -20}, {20, 20}}, rotation = 0), iconTransformation(origin = {-110, 50}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
      Modelica.Blocks.Interfaces.RealInput T(unit = "K") annotation(
        Placement(visible = true, transformation(origin = {-110, -50}, extent = {{-20, -20}, {20, 20}}, rotation = 0), iconTransformation(origin = {-110, -50}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
      Port port(redeclare package Medium = Medium) annotation(
        Placement(visible = true, transformation(origin = {100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      port.h_outflow = Medium.enthalpy(Medium.state_pT(port.p, T));
    end BaseSource;
    
    partial model TwoPort
      replaceable package Medium = Media.PartialMedium;
      Interfaces.Port port_in(redeclare package Medium = Medium) annotation(
        Placement(visible = true, transformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      TestExcercise.Interfaces.Port port_out(redeclare package Medium = Medium) annotation(
        Placement(visible = true, transformation(origin = {100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {102, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      port_in.p = port_out.p;
      port_in.m_flow = -port_out.m_flow;
    end TwoPort;
  end Interfaces;

  package Sources
    model MassFlow_T
      extends Interfaces.BaseSource(set(unit = "kg/s"));
    equation
      port.m_flow = -set;
    end MassFlow_T;
    
    model Pressure_T
      extends Interfaces.BaseSource(set(unit = "Pa"));
    equation
      port.p = set;
    end Pressure_T;
  end Sources;

  package HEX
  model PrescribedT
  extends Interfaces.TwoPort;
      Modelica.Blocks.Interfaces.RealInput Tset annotation(
        Placement(visible = true, transformation(origin = {-106, 60}, extent = {{-20, -20}, {20, 20}}, rotation = 0), iconTransformation(origin = {-96, 62}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
    equation
      port_out.h_outflow = Medium.enthalpy(Medium.state_pT(p = port_in.p, T = Tset));
      port_in.h_outflow = inStream(port_out.h_outflow);
  
//      Q_flow = port_in.m_flow*(port_out.h_outflow - inStream(port_in.h_outflow));
    end
PrescribedT;
  end HEX;

  package Tests
    model HEXtest
    replaceable package Water = Media.Water;
    
    TestExcercise.HEX.PrescribedT prescribedT(redeclare package Medium=Water) annotation(
        Placement(visible = true, transformation(origin = {0, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Sources.MassFlow_T massFlow_T(redeclare package Medium=Water) annotation(
        Placement(visible = true, transformation(origin = {-30, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  TestExcercise.Sources.Pressure_T pressure_T(redeclare package Medium=Water) annotation(
        Placement(visible = true, transformation(origin = {30, 0}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression realExpression11(y = 9 + 273.15) annotation(
        Placement(visible = true, transformation(origin = {-30, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression realExpression(y = 2) annotation(
        Placement(visible = true, transformation(origin = {-66, 6}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression realExpression111(y = 3e5) annotation(
        Placement(visible = true, transformation(origin = {110, 10}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression realExpression1(y = 18 + 273.15) annotation(
        Placement(visible = true, transformation(origin = {-66, -8}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression realExpression1111(y = 18 + 273.15) annotation(
        Placement(visible = true, transformation(origin = {110, -8}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
    equation
  connect(massFlow_T.port, prescribedT.port_in) annotation(
        Line(points = {{-20, 0}, {-10, 0}}));
  connect(prescribedT.port_out, pressure_T.port) annotation(
        Line(points = {{10, 0}, {20, 0}}));
  connect(realExpression.y, massFlow_T.set) annotation(
        Line(points = {{-54, 6}, {-40, 6}}, color = {0, 0, 127}));
  connect(realExpression1.y, massFlow_T.T) annotation(
        Line(points = {{-54, -8}, {-48, -8}, {-48, -4}, {-40, -4}}, color = {0, 0, 127}));
  connect(prescribedT.Tset, realExpression11.y) annotation(
        Line(points = {{-10, 6}, {-18, 6}, {-18, 20}, {-19, 20}}, color = {0, 0, 127}));
  connect(pressure_T.set, realExpression111.y) annotation(
        Line(points = {{42, 6}, {70.5, 6}, {70.5, 10}, {99, 10}}, color = {0, 0, 127}));
  connect(pressure_T.T, realExpression1111.y) annotation(
        Line(points = {{42, -4}, {70.5, -4}, {70.5, -8}, {99, -8}}, color = {0, 0, 127}));
    end HEXtest;
  end Tests;
  annotation(
    uses(Modelica(version = "4.0.0")));
end TestExcercise;
