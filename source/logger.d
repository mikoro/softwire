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

interface ILogger
{
	void log(MessageType type, string message);
	void logException(Exception ex);
	void logDebug(string message);
	void logInfo(string message);
	void logWarning(string message);
	void logError(string message);
}

class FileLogger : ILogger
{
	this(string fileName)
	{
		logFile = File(fileName, "w");
	}

	void log(MessageType type, string message)
	{
		auto time = Clock.currTime();
		logFile.writefln("%02d:%02d:%02d.%03d %s - %s", time.hour, time.minute, time.second, time.fracSec.msecs, type, message);
		logFile.flush();
	}

	void logException(Exception ex)
	{
		log(MessageType.Error, format("%s\n\n%s\n\n%s", typeid(ex).toString(), ex.msg, ex.info));
	}

	void logDebug(string message)
	{
		log(MessageType.Debug, message);
	}

	void logInfo(string message)
	{
		log(MessageType.Info, message);
	}

	void logWarning(string message)
	{
		log(MessageType.Warning, message);
	}

	void logError(string message)
	{
		log(MessageType.Error, message);
	}

	private
	{
		File logFile;
	}
}
