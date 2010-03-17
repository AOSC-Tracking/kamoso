/*
    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#include <QDebug>
#include <KLocale>
#include "webcamdialog.h"

WebcamDialog::WebcamDialog( QWidget *parent, const QString& name, KConfigSkeleton *config ): 
				KConfigDialog(parent,name,config),configManager(0)
{
	
}
WebcamDialog::~WebcamDialog()
{
	delete configManager;
}
bool WebcamDialog::hasChanged()
{
	Q_ASSERT(!configManager);
	if(KConfigDialog::hasChanged() == true || configManager->hasChanged() == true) {
		return true;
	}
	return false;
}
void WebcamDialog::setPageWebcamConfigManager(PageWebcamConfigManager* webcamManager)
{
	configManager = webcamManager;
}
void WebcamDialog::updateSettings()
{
	Q_ASSERT(!configManager);
	if(hasChanged() == true) {
		qDebug() << "Settings changed";
		configManager->updateDefaultValues();
		settingsChangedSlot();
	}
}

void WebcamDialog::updateWidgetsDefault()
{
	qDebug() << "updates widget!";
	KConfigDialog::updateWidgetsDefault();
	configManager->updateWidgetsDefault();
}