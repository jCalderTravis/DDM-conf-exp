function waitForInput
% Waits for mouse to be released and pressed

% Wait for all buttons to be released
pressed = 1;

while pressed

    [~, ~, buttons, ~, ~, ~] = GetMouse;

    if ~any(buttons); pressed = 0; end


end


%Wait until a key is pressed
while pressed == 0

    [~, ~, buttons, ~, ~, ~] = GetMouse;

    if any(buttons); pressed = 1; end


end


% Wait for all buttons to be released
pressed = 1;

while pressed

    [~, ~, buttons, ~, ~, ~] = GetMouse;

    if ~any(buttons); pressed = 0; end


end
