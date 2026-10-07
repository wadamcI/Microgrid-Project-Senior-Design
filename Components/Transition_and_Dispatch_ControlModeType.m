classdef Transition_and_Dispatch_ControlModeType < Simulink.IntEnumType
% Active-state (leaf) output of the Stateflow chart
% 'Microgrid Controller/Microgrid Supervisory Control/Transition and Dispatch Control'.
% Enumeral names must match the leaf state names in the chart.

    enumeration
        None (0)
        Steady_State_Islanded (1)
        Steady_State_Grid_Connected (2)
        Resynchronization (3)
        Unplanned_Islanding (4)
        Black_Start (5)
        Planned_Islanding (6)
    end
    methods (Static)
        function retVal = getDefaultValue()
            retVal = Transition_and_Dispatch_ControlModeType.None;
        end
    end
end
