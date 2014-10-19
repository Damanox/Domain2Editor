import std.stdio;
import std.file;
import std.mmfile;
import std.system;
import std.array;
import std.conv;
import std.string;
import std.utf;
import dfl.base;
import dfl.application;
import dfl.drawing;
import dfl.control;
import dfl.event;
import dfl.form;
import dfl.label;
import dfl.button;
import dfl.textbox;
import dfl.combobox;
import dfl.listbox;
import dfl.filedialog;
import dfl.menu;
import models;
import util;

class MainForm : Form
{
private:
    TextBox _pathText;
    ListBox _dataList;
    TextBox _nameText;
    ComboBox _typeText;
    TextBox _pointsText;
    TextBox _ownerText;
    ComboBox _capitalText;
    TextBox _xText;
    TextBox _yText;
    ContextMenu _saveMenu;
    DataStruct _data;
    int _selectedIndex = -1;

    public this()
    {
        text = "Domain2 Editor";
        startPosition = FormStartPosition.CENTER_SCREEN;
        formBorderStyle = FormBorderStyle.FIXED_3D;
        size = Size(600, 600);
        maximizeBox = false;

        _pathText = new TextBox();
        _pathText.bounds = Rect(5, 8, 425, 20);
        _pathText.text = "domain2.data";
        _pathText.parent = this;

        auto openButton = new Button();
        openButton.text = "..";
        openButton.bounds = Rect(435, 5, 40, 25);
        openButton.click ~= &chooseFile;
        openButton.parent = this;

        auto loadButton = new Button();
        loadButton.text = "Load";
        loadButton.bounds = Rect(480, 5, 50, 25);
        loadButton.click ~= &loadDataFile;
        loadButton.parent = this;

        auto saveButton = new Button();
        saveButton.text = "Save";
        saveButton.bounds = Rect(535, 5, 50, 25);
        saveButton.click ~= &showSaveMenu;
        saveButton.parent = this;

        _saveMenu = new ContextMenu();

        auto dataMenu = new MenuItem();
        dataMenu.text = ("Save as data");
        dataMenu.click ~= &saveDataFile;
        _saveMenu.menuItems.add(dataMenu);

        auto sevMenu = new MenuItem();
        sevMenu.text = ("Save as sev");
        sevMenu.click ~= &saveSevFile;
        _saveMenu.menuItems.add(sevMenu);

        _dataList = new ListBox();
        _dataList.bounds = Rect(5, 35, 270, 530);
        _dataList.selectedValueChanged ~= &selectItem;
        _dataList.parent = this;

        auto nameLabel = new Label();
        nameLabel.text = "Name:";
        nameLabel.bounds = Rect(290, 45, 50, 25);
        nameLabel.parent = this;

        _nameText = new TextBox();
        _nameText.bounds = Rect(340, 40, 240, 20);
        _nameText.parent = this;

        auto typeLabel = new Label();
        typeLabel.text = "Type:";
        typeLabel.bounds = Rect(290, 75, 50, 25);
        typeLabel.parent = this;

        _typeText = new ComboBox();
        _typeText.dropDownStyle = ComboBoxStyle.DROP_DOWN_LIST;
        _typeText.items.add("Flag Battle");
        _typeText.items.add("Bridge");
        _typeText.items.add("Crystals");
        _typeText.bounds = Rect(340, 70, 240, 20);
        _typeText.parent = this;

        auto pointsLabel = new Label();
        pointsLabel.text = "Points:";
        pointsLabel.bounds = Rect(290, 105, 50, 25);
        pointsLabel.parent = this;
        
        _pointsText = new TextBox();
        _pointsText.bounds = Rect(340, 100, 240, 20);
        _pointsText.parent = this;

        auto ownerLabel = new Label();
        ownerLabel.text = "Owner:";
        ownerLabel.bounds = Rect(290, 135, 50, 25);
        ownerLabel.parent = this;
        
        _ownerText = new TextBox();
        _ownerText.bounds = Rect(340, 130, 240, 20);
        _ownerText.parent = this;

        auto capitalLabel = new Label();
        capitalLabel.text = "Capital:";
        capitalLabel.bounds = Rect(290, 165, 50, 25);
        capitalLabel.parent = this;
        
        _capitalText = new ComboBox();
        _capitalText.dropDownStyle = ComboBoxStyle.DROP_DOWN_LIST;
        _capitalText.items.add("False");
        _capitalText.items.add("True");
        _capitalText.bounds = Rect(340, 160, 240, 20);
        _capitalText.parent = this;

        auto xLabel = new Label();
        xLabel.text = "Center.X:";
        xLabel.bounds = Rect(290, 195, 50, 25);
        xLabel.parent = this;
        
        _xText = new TextBox();
        _xText.bounds = Rect(340, 190, 240, 20);
        _xText.parent = this;

        auto yLabel = new Label();
        yLabel.text = "Center.Y:";
        yLabel.bounds = Rect(290, 225, 50, 25);
        yLabel.parent = this;
        
        _yText = new TextBox();
        _yText.bounds = Rect(340, 220, 240, 20);
        _yText.parent = this;

        auto applyButton = new Button();
        applyButton.text = "Apply";
        applyButton.bounds = Rect(535, 535, 50, 25);
        applyButton.click ~= &apply;
        applyButton.parent = this;
    }

    void chooseFile(Control sender, EventArgs e)
    {
        auto dialog = new OpenFileDialog();
        dialog.filter = "Data files(*.data)|*.data|All files(*.*)|*.*";
        if(dialog.showDialog() != DialogResult.OK)
            return;
        _pathText.text = dialog.fileName;
    }

    void showSaveMenu(Control sender, EventArgs e)
    {
        _saveMenu.show(sender, Point(location.x + sender.location.x + 5, location.y + sender.location.y + 52));
    }

    void loadDataFile(Control sender, EventArgs e)
    {
        auto filename = _pathText.text;
        if(!filename.exists)
            return;
        _data = loadData(filename);
        _dataList.items.clear();
        foreach(domain; _data.domains)
            _dataList.items.add(domain.name.text);
    }

    void saveDataFile(MenuItem sender, EventArgs e)
    {
        if(!_data.loaded)
            return;
        auto filename = _pathText.text;
        saveData(filename, _data);
    }

    void saveSevFile(MenuItem sender, EventArgs e)
    {
        if(!_data.loaded)
            return;
        auto filename = _pathText.text;
        auto sev = SevStruct(_data);
        saveSev(filename, sev);
    }

    void selectItem(Control sender, EventArgs e)
    {
        _selectedIndex = _dataList.selectedIndex;
        if(_selectedIndex == -1)
            return;
        auto domain = _data.domains[_selectedIndex];
        _nameText.text = domain.name.text;
        _typeText.selectedIndex = domain.battleType;
        _pointsText.text = domain.points.text;
        _ownerText.text = domain.owner.text;
        _capitalText.selectedIndex = domain.capital;
        _xText.text = domain.x.text;
        _yText.text = domain.y.text;
    }

    void apply(Control sender, EventArgs e)
    {
        if(_selectedIndex == -1)
            return;
        _data.domains[_selectedIndex].name = _nameText.text.to!(wchar[]);
        _data.domains[_selectedIndex].battleType = _typeText.selectedIndex;
        _data.domains[_selectedIndex].points = _pointsText.text.to!int;
        _data.domains[_selectedIndex].owner = _ownerText.text.to!int;
        _data.domains[_selectedIndex].capital = _capitalText.selectedIndex;
        _data.domains[_selectedIndex].x = _xText.text.to!int;
        _data.domains[_selectedIndex].y = _yText.text.to!int;
        _dataList.items[_selectedIndex] = _nameText.text;
        auto len = _data.domains[_selectedIndex].name.length;
        for(auto i = len; i < 16; i++)
            _data.domains[_selectedIndex].name ~= "\0"w;
        _dataList.selectedIndex = _selectedIndex;
    }
}

void main()
{
    Application.enableVisualStyles();
    Application.run(new MainForm());
}

DataStruct loadData(string filename)
{
    auto file = new MmFile(filename);
    auto buffer = cast(ubyte[])file[];
    return buffer.readModel!DataStruct(1);
}

SevStruct loadSev(string filename)
{
    auto file = new MmFile(filename);
    auto buffer = cast(ubyte[])file[];
    return buffer.readModel!SevStruct(1);
}

void saveData(string filename, DataStruct data)
{
    auto file = File(filename, "wb");
    auto buffer = appender!(const ubyte[])();
    buffer.writeModel(data);
    file.rawWrite(buffer.data);
}

void saveSev(string filename, SevStruct data)
{
    auto file = File(filename, "wb");
    auto buffer = appender!(const ubyte[])();
    buffer.writeModel(data);
    file.rawWrite(buffer.data);
}