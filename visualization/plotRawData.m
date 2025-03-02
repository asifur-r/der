function plotRawData(folder, ids)
	
	figure

	% Get all csv files in the folder
	files = dir(fullfile(folder, '*.csv'));

	% If no ids provided, the plot all data
	if nargin < 2; dataSet = 1:length(files); else; dataSet = ids;  end

	for i = dataSet

		file = fullfile(folder, files(i).name);
		T = readtable(file, 'VariableNamingRule', 'Preserve');
		
		var1 = T.Properties.VariableNames{2}; % Disp
		var2 = T.Properties.VariableNames{3}; % Load
		
		plot(T.(var1), T.(var2))%, 'k')

		txtpt = round(length(T.(var1))/2); % mid point
		
		% Use regular expression to match the number before .csv
		tokens = regexp(file, '_(\d+)\.csv$', 'tokens');

		if ~isempty(tokens)
			txtstr = tokens{1}{1};
		else
			error("Data files should have *_x.csv format, where x is an integer");
		end

		text(T.(var1)(txtpt), T.(var2)(txtpt), txtstr, 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', 'blue');
	
		hold on

	end

	title(folder, 'Interpreter', 'none')

end
