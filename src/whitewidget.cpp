/*************************************************************************************
 *  Copyright (C) 2008 by Aleix Pol <aleixpol@gmail.com>                             *
 *  Copyright (C) 2008 by Alex Fiestas <alex@eyeos.org>                              *
 *                                                                                   *
 *  This program is free software; you can redistribute it and/or                    *
 *  modify it under the terms of the GNU General Public License                      *
 *  as published by the Free Software Foundation; either version 3                   *
 *  of the License, or (at your option) any later version.                           *
 *                                                                                   *
 *  This program is distributed in the hope that it will be useful,                  *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                    *
 *  GNU General Public License for more details.                                     *
 *                                                                                   *
 *  You should have received a copy of the GNU General Public License                *
 *  along with this program; if not, write to the Free Software                      *
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA   *
 *************************************************************************************/

#include "whitewidget.h"
#include <QPaintEvent>
#include <QPainter>
#include <QTimer>
#include <KLocale>
#include <KWindowSystem>

WhiteWidget::WhiteWidget(QWidget* parent)
	: QWidget(parent)
{
	setAutoFillBackground(false);
}


void WhiteWidget::paintEvent (QPaintEvent* paintEvent)
{
	QPainter painter(this);
	
	painter.setBrush(Qt::white);
	painter.drawRect(paintEvent->rect());
	painter.drawText(paintEvent->rect().center(), i18n("Smile! :)"));
}