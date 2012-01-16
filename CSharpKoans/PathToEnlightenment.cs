﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using CSharpKoans.Core;

namespace CSharpKoans
{
    public class PathToEnlightenment
    {

        public IList<KoanContainer> containers
        {
            get
            {
                return new List<KoanContainer>() { 
                    new AboutAsserts() , 
                    new AboutLambdas(),
                    new AboutLinq()
                };
            }
        }



        public void Execute()
        {
            var runner = new KoanRunner(containers);
            var result = runner.ExecuteKoans();
            if (result is Success) Console.WriteLine(result.Message);
            else
            {
                var failure = result as Failure;
                Console.WriteLine(result.Message);
                Console.WriteLine("");
                Console.WriteLine("");
                Console.WriteLine("");
                Console.WriteLine("");
                Console.WriteLine("You have not yet reached enlightenment ...");
                Console.WriteLine(failure.Message);
                Console.WriteLine("");
                Console.WriteLine("Please meditate on the following code:");
                Console.WriteLine(failure.Exception.StackTrace);
                Console.WriteLine("");
                Console.WriteLine("");
                Console.WriteLine("");
                Console.WriteLine("");
                Console.WriteLine("Press any key to continue...");
                System.Console.ReadKey();
            }
        }

    }
}
