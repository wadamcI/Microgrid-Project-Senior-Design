function openCellBlock()

% Copyright 2026 The MathWorks, Inc.

blockPath = [gcb,'/','PV Array'];
blockHandle = get_param(blockPath, 'Handle');
% Don't break the library link: Simscape blocks must stay linked, and the
% parameters can be edited through the linked block's dialog.
open_system(blockHandle,'Mask');
end