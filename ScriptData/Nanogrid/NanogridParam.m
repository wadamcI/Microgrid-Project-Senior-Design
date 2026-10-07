% Nanogrid parameters: one mid-size business building
% 60 Hz, 690 V inverter side, 11 kV bus
% Ratings follow the block masks: kW for plant ratings, SI for everything else.
% Filter/line impedances are the MathWorks example values; don't scale them
% with rating (scaling them down made the BESS current controller unstable).

Ts = 5E-5;                          % s, simulation sample time
systemFrequency = 60;               % Hz
busVoltage = 11000;                 % V, nanogrid AC bus (line-line RMS)
bessVoltage = 1500;                 % V, battery DC voltage

%% Scenario inputs (previously from NormalOperation.m)
ref.QBESS1MW = 0;                   % var, BESS reactive power reference
solarInsolationChange = 100;        % s, irradiance step time (1000 -> 800 W/m^2); e.g. 1.5 to test a solar drop

%% Load
nanoLoad.P = 500e3;                 % W, building peak load
nanoLoad.pf = 0.95;
nanoLoad.Q = nanoLoad.P*tan(acos(nanoLoad.pf)); % var (~164e3)

% Small fixed resistive load (Wye-Connected Load) for solver robustness.
% The Dynamic Load gets nanoLoad.P - baseLoad.P so the total stays nanoLoad.P.
baseLoad.P = 0.02*nanoLoad.P;       % W
baseLoad.Q = 0;                     % var

%% Solar plant (300 kW rooftop)
PV = struct;
PV.plantRating = 300;               % kW
PV.nParallel = 34;                  % panels in parallel (30 in series x 34 x 300 W ~ 306 kW)
PV.transformerVA = 1e6;             % VA, 690 V / 11 kV transformer rating
PV.Vac = 690;                       % V
PV.frequency = systemFrequency;     % Hz
PV.baseVoltageDC = 1500;            % V
PV.converterEfficiency = 100;       % %
PV.switchingFrequency = 20;
PV.panelRating = 300;               % W
PV.Voc = 44.8;                      % V
PV.Isc = 8.71;                      % A
PV.irradianceSTC = 1000;            % W/m^2
PV.temperatureSTC = 298;            % K
PV.alpha = 0.005;
PV.beta = -0.005;
PV.controllerTSensor = 0.0001;      % s
PV.controllerKpIc = 0.01;
PV.controllerKiIc = 0.1;
PV.controllerKpv = 0.1;
PV.controllerKiv = 1;

PVInverter = struct;
PVInverter.iMaxPU = 1.2;
PVInverter.capacitance = 0.04;      % F
PVInverter.filterInductance = 1e-5; % H
PVInverter.filterResistance = 1e-3; % Ohm

%% Battery (500 kW / 1 MWh, grid forming)
bessSystem = struct;
bessSystem.plantRating = 500;       % kW
bessSystem.capacityAh = 667;        % Ah  (1 MWh / 1500 V, 2 hours)
bessSystem.transformerVA = 1e6;     % VA, 690 V / 11 kV transformer rating
bessSystem.initialSOC = 0.9;
bessSystem.maxSOC = 0.95;
bessSystem.minSOC = 0.1;
bessSystem.frequency = systemFrequency;
bessSystem.Vdc = 1500;              % V
bessSystem.Vac = 690;               % V
bessSystem.filterInductance = 1e-5; % H
bessSystem.filterResistance = 1e-3; % Ohm
bessSystem.switchingFrequency = 20;
bessSystem.converterEfficiency = 100;   % %
bessSystem.iMaxPU = 1.2;
bessSystem.activeDroop = 1e-4;
bessSystem.reactiveDroop = 0.02;

gfmInverter = struct;
gfmInverter.measurementSampleTime = Ts;
gfmInverter.freqMeasTimeConst = 0.001;
gfmInverter.L = 1.325e-4;           % H
gfmInverter.lineResistance = 0.08;  % Ohm
gfmInverter.droopControl.freqSlopeMp = 0.01;
gfmInverter.droopControl.lpfTimeConst = 0.015;
gfmInverter.droopControl.T1 = 0.005;
gfmInverter.droopControl.T2 = 0.006;
gfmInverter.droopControl.sampleTime = Ts;
gfmInverter.vsm.inertiaConstant = 1;
gfmInverter.vsm.dampingCoefficent = 20;
gfmInverter.vsm.freqDroop = 5;
gfmInverter.vsm.PmeasTimeConst = 0.001;
gfmInverter.vsm.maxDampingPower = 0.9;
gfmInverter.vsm.minDampingPower = -0.6;
gfmInverter.Qcontrol.voltageDroop = 5;
gfmInverter.Qcontrol.QmeasTimeConst = 0.001;
gfmInverter.Qcontrol.voltageReference = 1;
gfmInverter.currentLimit.virImpResistanceCoeff = 0.1875;
gfmInverter.currentLimit.virImpXbyR = 13.2;
gfmInverter.currentLimit.viCurrentLimit = 1.2;
gfmInverter.currentLimit.viFilterTimeConst = 0.001;
gfmInverter.currentLimit.maxSaturationCurrent = 1.4;
gfmInverter.currentLimit.maxSaturationDelay = 0.001;
gfmInverter.currentLimit.satCurrentRunTime = 0.001;
gfmInverter.controller.CurrentControlSampleTime = Ts;
gfmInverter.controller.VoltageControlSampleTime = Ts;
gfmInverter.controller.ctControllerKp = 2;
gfmInverter.controller.ctControllerKi = 10;
gfmInverter.controller.voltControllerKp = 3;
gfmInverter.controller.voltControllerKi = 1.5;
gfmInverter.controller.voltageMaxId = 1.8;
gfmInverter.controller.voltageMinId = -1.8;
gfmInverter.controller.voltageMaxIq = 1.8;
gfmInverter.controller.voltageMinIq = -1.8;
gfmInverter.controller.voltMeasTimeConst = 0.005;

%% Power quality limits (60 Hz)
powerQuality.maxVoltage = 1.1;      % pu
powerQuality.minVoltage = 0.9;      % pu
powerQuality.maxFrequency = 60.5;   % Hz
powerQuality.minFrequency = 59.5;   % Hz
