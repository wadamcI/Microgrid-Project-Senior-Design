function applyNanogridSettings(mdl)
% Point the Nanogrid block parameters at the variables in NanogridParam.m,
% so sizing changes only need edits to NanogridParam.m.
% Run once with the model open, check it, then save the model (Ctrl+S).

arguments
    mdl = 'Nanogrid';
end

evalin('base', 'NanogridParam;');  % make sure the variables exist (also run by PreLoadFcn)

% Solar plant
set_param([mdl '/Solar Plant Integrated'], 'nParallel', 'PV.nParallel');

% BESS: keep the mask's initial SOC consistent with the Battery block
set_param([mdl '/BESS Integrated'], 'initialSOC', 'bessSystem.initialSOC');

% 690 V / 11 kV transformers
setTransformerRating([mdl '/Transformer'], 'PV.transformerVA');
setTransformerRating([mdl '/Transformer1'], 'bessSystem.transformerVA');

% Loads: Dynamic Load carries everything except the fixed base load
set_param([mdl '/Constant10'], 'Value', 'nanoLoad.P - baseLoad.P');
set_param([mdl '/Constant9'], 'Value', 'nanoLoad.Q');
set_param([mdl '/Dynamic Load (Three-Phase)'], 'FRated', 'systemFrequency');
set_param([mdl '/Load1'], 'FRated', 'systemFrequency', 'Vmag0', 'busVoltage');

disp('Nanogrid settings applied. Check with Ctrl+D, then save the model.');
end

function setTransformerRating(transformerBlock, value)
inner = find_system(transformerBlock, 'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
    'MatchFilter', @Simulink.match.allVariants, 'Regexp', 'on', 'Name', 'Two-Winding Transformer');
for k = 1:numel(inner)
    set_param(inner{k}, 'SRated', value);
end
end
