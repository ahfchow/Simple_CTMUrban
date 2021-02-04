% -----------------------------------------------------------------
function [control] = ControlVector(Link,SignalControl,TotalTimeStep) 

% control vector  
% binary: 0 - RED; 1-GREEN 
% each link should only be associated with one control vector (?) 

control = ones(length(Link),TotalTimeStep);

for s = 1:length(SignalControl) 
    for c = 1:floor(TotalTimeStep/SignalControl(s).Cycle)       
        for stage = 1:size(SignalControl(s).Restricted,1)
            if (stage == 1)
                for t = 1+SignalControl(s).Offset+SignalControl(s).Cycle*(c-1):...
                        SignalControl(s).Offset+SignalControl(s).StageEnd(stage) + SignalControl(s).Cycle*(c-1) 
                    for r = 1:size(SignalControl(s).Restricted,2)
                        if SignalControl(s).Restricted(stage,r) > 0
                            control(SignalControl(s).Restricted(stage,r),t) = 0;
                        end
                    end
                end
            else
                for t = 1+SignalControl(s).Offset+SignalControl(s).StageEnd(stage-1)+SignalControl(s).Cycle*(c-1):...
                        SignalControl(s).Offset+SignalControl(s).StageEnd(stage)+SignalControl(s).Cycle*(c-1) 
                    for r = 1:size(SignalControl(s).Restricted,2)
                        if SignalControl(s).Restricted(stage,r) > 0
                            control(SignalControl(s).Restricted(stage,r),t) = 0;
                        end
                    end
                end
            end
        end
    end
end