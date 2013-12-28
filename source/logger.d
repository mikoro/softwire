/**
 * A simple logger class.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module logger;

import std.datetime;
import std.stdio;
import std.string;

enum MessageType
{
	Debug,
	Info,
	Warning,
	Error
};

class Logger
{
	abstract void logMessage(MessageType type, lazy string message);
	abstract void logThrowable(Throwable ex);

	final void logDebug(Args...)(lazy string message, Args args)
	{
		logMessage(MessageType.Debug, format(message, args));
	}

	final void logInfo(Args...)(lazy string message, Args args)
	{
		logMessage(MessageType.Info, format(message, args));
	}

	final void logWarning(Args...)(lazy string message, Args args)
	{
		logMessage(MessageType.Warning, format(message, args));
	}

	final void logError(Args...)(lazy string message, Args args)
	{
		logMessage(MessageType.Error, format(message, args));
	}
}

class FileAndConsoleLogger : Logger
{
	this(string fileName)
	{
		logFile = File(fileName, "w");
	}

	override void logMessage(MessageType type, lazy string message)
	{
		auto time = Clock.currTime();
		string formattedMessage = format("%02d:%02d:%02d.%03d %s - %s", time.hour, time.minute, time.second, time.fracSec.msecs, type, message);
		writeln(formattedMessage);
		logFile.writefln(formattedMessage);
		logFile.flush();
	}

	override void logThrowable(Throwable ex)
	{
		logMessage(MessageType.Error, format("%s: %s", typeid(ex).toString(), ex.msg));
	}

	private File logFile;
}
