﻿using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using RocksDbSharp;
using System.Text;

namespace RocksDbSharpTest
{
    [TestClass]
    public class TestBinaryComparer
    {
        [TestMethod]
        public void TestCompare()
        {
            var comparer = BinaryComparer.Default;

            var forward = StringComparer.OrdinalIgnoreCase.Compare("a", "b");
            var backward = -forward;

            AssertCompare(comparer, forward, "B", "b");
            AssertCompare(comparer, backward, "b", "B");

            AssertCompare(comparer, forward, "aB", "ab");
            AssertCompare(comparer, backward, "ab", "aB");

            AssertCompare(comparer, forward, "cB", "cb");
            AssertCompare(comparer, backward, "cb", "cB");

            AssertCompare(comparer, forward, "b", "bb");
            AssertCompare(comparer, backward, "bb", "b");
        }

        [TestMethod]
        public void TestPrefixEquals()
        {
            var comparer = BinaryComparer.Default;

            Assert.IsTrue(comparer.PrefixEquals(AsciiBytes("aaa"), AsciiBytes("aaa"), 1));
            Assert.IsTrue(comparer.PrefixEquals(AsciiBytes("aaa"), AsciiBytes("aaa"), 3));
            Assert.IsTrue(comparer.PrefixEquals(AsciiBytes("aaa"), AsciiBytes("aaa"), 5));

            Assert.IsTrue(comparer.PrefixEquals(AsciiBytes("aaa"), AsciiBytes("aaX"), 1));
            Assert.IsTrue(comparer.PrefixEquals(AsciiBytes("aaa"), AsciiBytes("aaX"), 2));
            Assert.IsFalse(comparer.PrefixEquals(AsciiBytes("aaa"), AsciiBytes("aaX"), 3));
            Assert.IsFalse(comparer.PrefixEquals(AsciiBytes("aaa"), AsciiBytes("aaX"), 5));

            Assert.IsTrue(comparer.PrefixEquals(AsciiBytes("aaa"), AsciiBytes("aaaX"), 1));
            Assert.IsTrue(comparer.PrefixEquals(AsciiBytes("aaa"), AsciiBytes("aaaX"), 3));
            Assert.IsFalse(comparer.PrefixEquals(AsciiBytes("aaa"), AsciiBytes("aaaX"), 4));

            Assert.IsTrue(comparer.PrefixEquals(AsciiBytes("aaaX"), AsciiBytes("aaa"), 1));
            Assert.IsTrue(comparer.PrefixEquals(AsciiBytes("aaaX"), AsciiBytes("aaa"), 3));
            Assert.IsFalse(comparer.PrefixEquals(AsciiBytes("aaaX"), AsciiBytes("aaa"), 4));
        }

        private byte[] AsciiBytes(string v)
        {
            return Encoding.ASCII.GetBytes(v);
        }

        private void AssertCompare(BinaryComparer comparer, int expected, string v1, string v2)
        {
            Assert.AreEqual(expected, comparer.Compare(Encoding.UTF8.GetBytes(v1), Encoding.UTF8.GetBytes(v2)), string.Format("{0} -> {1}", v1, v2));
        }
    }
}
